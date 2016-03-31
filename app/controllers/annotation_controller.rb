require 'rubygems'
require 'json'
require 'uuid'
require 'mongo'
require 'annotation_solr_loader'

include Mongo

class AnnotationController < ApplicationController

  before_filter :authenticate_user!

  def show
    # Generate annotation ID as URI,  server + "/annotation/"
    base_url = Rails.configuration.annotation_server.url
    base_url += '/' unless base_url.ends_with?('/')
    annotation_uri = "#{base_url}annotation/#{params[:id]}"
    annotation = Annotation.where({'@id' => annotation_uri}).first
    authorize! :read, annotation
    respond_to do |format|
      format.json {
        render json: annotation.to_iiif
      }
    end
  end

  def create
    begin
      # Extract annotation fields from Annotorius format
      json = params['annotation']
      raise ArgumentError if json.nil?
      annotation_data = AnnotationData.new(json)

      # Get current project from request, based on user access
      # Anonymous annotation is not permitted
      raise SecurityError unless user_signed_in?
      user = get_user
      project = Project.where({:project_id => annotation_data.project_id}).first
      raise SecurityError if project.nil?

      # Verify user can create annotations for project[s]
      authorize! :write, project

      # Get annotation annotation_list for canvas/source for this project
      annotation_list =  annotation_data.list_id ? AnnotationList.where("@id" => annotation_data.list_id).first :
          AnnotationList.find_or_create_list(annotation_data.project_id, annotation_data.canvas, {motivation: annotation_data.motivation})

      # Generate annotation ID as URI,  server + "/annotation/" + UUID
      base_url = Rails.configuration.annotation_server.url
      base_url += '/' unless base_url.ends_with?('/')
      annotation_data.uri = "#{base_url}annotation/" + UUID.generate

      # Intersect user's and project's groups to determine effective permissions for this annotation
      # TODO: determine use cases for permissions; use controls needed?
      common_groups = (user.groups + ['public']) & project.permissions

      # Assemble annotation data and add annotation to database
      annotation = Annotation.create_annotation(user,
                                                common_groups,
                                                annotation_data,
                                                annotation_list)

      # Update SOLR via delayed job
      #AnnotationSolrLoader.new.load_single_annotation(annotation)
      AnnotationSolrLoader.new.delay.load_single_annotation(annotation)

      # track event
      AnnotationActivity.create_new(current_user,
                                   'created',
                                   annotation_data,
                                   common_groups)
      # return annotation ID
      respond_to do |format|
        format.json {
          render json:  { '_id' => annotation_data.uri, 'annotation_list_uri' => annotation_list['@id'] }, status: 201
        }
      end
    rescue ArgumentError => ex
      logger.error ex
      render status: 400
    rescue SecurityError
      render status: 403
    ensure
    end
  end

  def update
    begin
      json = params['annotation']
      raise ArgumentError if json.nil?
      annotation_data = AnnotationData.new(json)

      annotation_data.uri = params['annotation']['@id']
      raise ArgumentError if annotation_data.uri.nil?
      raise SecurityError unless user_signed_in?
      user = get_user

      project = Project.where({:project_id => annotation_data.project_id}).first
      raise SecurityError if project.nil?
      # Verify user can create annotations for project[s]
      authorize! :write, project

      annotation = Annotation.where({:@id => annotation_data.uri, active: true}).first
      raise SecurityError if annotation.nil?
      authorize! :write, annotation

      # Update annotation for new record and save
      new_annotation = annotation.attributes.clone
      new_annotation['version'] += 1;
      new_annotation['action'].append({
                                      'event' => 'modified',
                                      'agent' => user.personal_group,
                                      'date' => DateTime.now().to_s
                                  })
      new_annotation['resource']['chars'] = annotation_data.text
      new_annotation.delete('_id')
      annotation_to_solr = Annotation.create(new_annotation)

      #update SOLR via delayed_job
      AnnotationSolrLoader.new.delay.load_single_annotation(annotation_to_solr)

      # Mark previous annotation as inactive
      annotation.update_attributes(active: false)

      # track event
      puts 'current_user: ' + current_user.last_name
      AnnotationActivity.create_new(current_user,
                                   'edited',
                                   annotation_data,
                                   project.groups & user.groups)

      # return annotation ID for use by Annotorious
      respond_to do |format|
        format.json {
          render json:  { 'success' => true }
        }
      end
    rescue ArgumentError => error
      render status: 400
    rescue SecurityError => error
      render status: 403
    ensure
    end
  end

  def destroy
    begin
      annotation_uri = request.original_url
      raise ArgumentError if annotation_uri.nil?
      raise SecurityError unless user_signed_in?
      user = get_user

      annotation = Annotation.where({:@id => annotation_uri, active: true}).first
      raise SecurityError if annotation.nil?
      authorize! :delete, annotation

      annotation['active'] = false
      annotation['action'].append({
                                    'event' => 'deleted',
                                    'agent' => user.uid,
                                    'date' => DateTime.now.to_s
                                  })
      annotation.save

      #delayed_job: send annotation above to load_single_annotation, which will check annotation['active'] and see that it is false and delete it
      #AnnotationSolrLoader.new.load_single_annotation(annotation)
      AnnotationSolrLoader.new.delay.load_single_annotation(annotation)

      # return success
      respond_to do |format|
        format.json {
          render json:  { 'success' => true }
        }
      end
    rescue ArgumentError
      render status: 400
    rescue SecurityError
      render status: 403
    ensure
    end
  end

  def index
    begin
      canvas = params['canvas']
      raise ArgumentError if canvas.nil?
      raise SecurityError unless user_signed_in?
      # get logged in user's groups
      groups = get_user_read_groups true
      # now query Mongo
      annotations = Annotation.where({'canvas' => canvas, 'active' => true, 'permissions.read' => { '$in' => groups }}).to_a
      results = Array.new
      # mark annotations as not editable if user does not have write permission
      annotations.each do |annotation|
        if can? :read, annotation
          anno = annotation.to_iiif
          can_edit =  can? :write, annotation
          anno['toolSupport']  = {
              editable: can_edit
          }
          results.push(anno)
        end
      end
      # return annotations
      respond_to do |format|
        format.json {
          render json: results
        }
      end
    rescue ArgumentError
      render status: 400
    rescue SecurityError
      render status: 403
    ensure
    end
  end


  class AnnotationData

    attr_reader :canvas_label, :manifest, :manifest_label, :text, :project_id, :on, :list_id, :motivation
    attr_accessor :uri

    def initialize(data)
      @text = data['resource']['chars']
      @motivation = data['motivation'] || 'sc:Describing'

      @on = data['on']
      # parse selector component values, be sure they are integers
      @canvas, selector = @on.split('#xywh=')
      unless selector.nil?
        selector = selector.split(',').map(&:to_i).join(',')
        @on = "#{@canvas}#xywh=#{selector}"
      end

      # application-specific values for supporting lists, activity feed
      #@canvas = data['toolSupport']['canvas']
      @canvas_label = data['toolSupport']['canvasLabel']
      @manifest = data['toolSupport']['manifest']
      @manifest_label = data['toolSupport']['manifestLabel']
      @project_id = data['toolSupport']['projectId']
      @list_id = data['toolSupport']['listId']
    end

    def canvas
      @on.split('#xywh=')[0]
    end

    def selector
      @on.split('#xywh=')[1]
    end

  end

end
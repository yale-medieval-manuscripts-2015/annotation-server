require 'rubygems'
require 'json'
require 'uuid'
require 'mongo'

include Mongo

class AnnotationListsController < ApplicationController

  before_filter :authenticate_user!

  def index
    canvas_uri = params[:canvas]
    #TODO : Decide whether to restrict by manifest or current project
    #manifest_uri = params[:manifest]
    #project_id = params[:projectId]
    groups = get_user_read_groups false

    projects = Project.in({'permissions' => groups}).all.pluck(:project_id)
    iiif_lists = []
    unless projects.nil? || projects.empty?
      annotation_lists = AnnotationList.in('project_id' => projects).where({canvas: canvas_uri}).to_a
      annotation_lists.each { |list|
          iiif_lists.push(list['@id'])
      }
    end

    respond_to do |format|
      format.any {
        render json: iiif_lists.to_json, :content_type=>'application/json'
      }
    end
  end

  def show
    # TODO authorize access to lists' project???

    # now query Mongo
    annotation_list = AnnotationList.find(params[:id])
    annotations = annotation_list.annotations

    results = []
    annotations.each do |annotation|
      if can? :read, annotation
        results.push annotation.to_iiif(false)
      end
    end

    # add IIIF Metadata context
    iiif_list = annotation_list.to_iiif
    iiif_list['resources'] = results

    # return annotations
    respond_to do |format|
      format.any {
        render json: iiif_list.to_json, :content_type=>'application/json'
      }
    end
  end

  # POST /list
  # POST /list.json
  def create
    list_data = params[:annotation_list]
    # required arguments
    project_id = list_data[:project_id]
    canvas_id = list_data[:canvas_id]
    raise ArgumentError if project_id.nil? or project_id.empty? or canvas_id.nil? or canvas_id.empty?
    # TODO: one list per canvas + motivation ?
    @annotation_list = AnnotationList.find_or_create_list(project_id, canvas_id, list_data)
    authorize! :create, @annotation_list
    respond_to do |format|
      if @annotation_list.save
        format.html { redirect_to @annotation_list, notice: 'Annotation list was successfully created.' }
        format.json { render json: @annotation_list.to_iiif, status: :created, location: @annotation_list }
      else
        format.html { render action: "new" }
        format.json { render json: @annotation_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /list/1
  # DELETE /list/1.json
  def destroy
    @annotation_list = AnnotationList.find(params[:id])
    authorize! :delete, @annotation_list
    @annotation_list.destroy
    respond_to do |format|
      format.html { redirect_to annotation_lists_url }
      format.json { head :no_content }
    end
  end

end
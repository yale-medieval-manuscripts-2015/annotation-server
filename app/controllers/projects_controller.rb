require 'rubygems'
require 'json'
require 'uuid'
require 'mongo'

include Mongo

class ProjectsController < ApplicationController

  before_filter :authenticate_user!

  def index

  end

  def show
    project = find_project(params[:id])
    raise ArgumentError if project.nil?
    # Check user permission
    authorize! :read, project

    @project = project
    @mirador_configuration = project['miradorConfiguration']

    manifest_uri = params[:manifest_uri]
    # TODO : this should be the canvas_uri, but Mirador appears to be using the label
    canvas_label = params[:canvas_label]
    show_thumbs @mirador_configuration, manifest_uri, canvas_label if (manifest_uri)

    @show_annotation_button = can? :write, project
    @mirador_configuration = @mirador_configuration.to_json
    render layout: 'project'
  end

# @param [Hash] mirador_configuration
# @param [String] manifest_uri
# @param [String] canvas_label
  def show_thumbs mirador_configuration, manifest_uri, canvas_label

    # Don't show the thumbnail widget, it delays loading of the image in the image widget
    #thumbnail_widget = {"height" => 500.0, "type" => "thumbnailsView", "width" => 400.0}
    image_widget = {"height" => 500.0, "type" => "imageView", "width" => 400.0, "openAt" => canvas_label}

    mirador_configuration.each do |config|
       if config['manifestUri'] == manifest_uri
         if config['widgets'].nil?
           config['widgets'] = []
           config['widgets'].push(image_widget) unless canvas_label.nil?
         else
            #has_thumbnail_widget = false
            has_image_widget = false
            config['widgets'].each do |widget|
              #has_thumbnail_widget = true if widget['type'] == 'thumbnailsView'
              has_image_widget == true if widget['type'] == 'imageView' and widget['openAt'] == canvas_label
            end
            #config['widgets'].push(thumbnail_widget) unless has_thumbnail_widget
            config['widgets'].push(image_widget) unless has_image_widget or canvas_label.nil?
         end
       end
    end
  end

  def find_project project_id
    groups = get_user_read_groups true
    project = Project.where( :project_id => project_id).in( :permissions => groups ).first()
    return project
  end

end
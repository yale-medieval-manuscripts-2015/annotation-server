require 'rubygems'
require 'json'
require 'uuid'
require 'mongo'

include Mongo

class CanvasController < ApplicationController

  def show
    # TODO: no security for now, if you have the UUID you can view the canvas
    uri = request.base_url + "/canvas/#{params[:id]}"
    canvas = Canvas.find(uri)
    # return canvas
    respond_to do |format|
      format.any {
        render json: canvas.to_iiif, :content_type=>'application/json'
      }
    end
  end

end
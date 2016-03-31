require 'rubygems'
require 'json'

include Mongo

class Manifest
  include Mongoid::Document
  store_in collection: "manifests"

  field :label, type: String
  field :description, type: String
  field :manifest_uri, type: String
  field :manifest_json, type: Hash, default: {}
  field :permissions, type: Hash
  field :updated_at, type: Time

  validates_presence_of :manifest_uri
  validates_uniqueness_of :manifest_uri

  attr_accessible :label, :description, :manifest_json, :manifest_uri, :updated_at

  def get_canvases
    all_canvases = Array.new
    sequences = manifest_json['sequences'] || Array.new
    sequences.each do |sequence|
      canvases = sequence['canvases']
      next if canvases.nil?
      canvases.each do |canvas|
        all_canvases.push canvas if canvas['label']
      end
    end
    return all_canvases
  end

end

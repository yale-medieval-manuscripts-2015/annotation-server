class Canvas
  include Mongoid::Document
  store_in collection: "canvases"

  field :@id, type: String
  field :@type, type: String, default: 'sc:Canvas'
  field :@context, type: String
  field :label, type: String
  field :manifests, type: Array, default: Array.new

  validates_presence_of :@id, :@type, :@context, :manifests
  validates :@id, uniqueness: true

  # @param [Manifest] manifest
  def self.update_canvases_for_manifest(manifest)
    # delete
    Canvas.in(manifests: manifest.manifest_uri).each do |canvas|
      canvas.manifests.delete(manifest.manifest_uri)
      if canvas.manifests.empty?
        canvas.destroy
      else
        canvas.save
      end
    end
    # create or update
    canvases = manifest.get_canvases
    canvases.each do |canvas|
      canvas_uri = canvas['@id']
      canvas_id = canvas_uri
      next if canvas_id.nil?
      new_canvas = Canvas.find_or_initialize_by('@id' => canvas_uri)
      new_canvas.id = canvas_id
      new_canvas.assign_attributes(canvas)
      new_canvas.manifests.push(manifest.manifest_uri) unless new_canvas.manifests.include?(manifest.manifest_uri)
      new_canvas.attributes['@context'] = manifest.manifest_json['@context']
      new_canvas.save
    end
  end

  # @return [String]
  def primary_image_url
    url = nil
    if attributes['images']
      resources = attributes['images']['resource']
      return if resources.nil? || resources.empty? || resources['@type'].nil?
      annotation_type = resources['@type']
      if annotation_type == 'dctypes:Image'
        url = resources['@id']
      elsif annotation_type == 'oa:Choice'
        url = resources['default']['@id'] unless resources['default']
      end
    end
    return url
  end

  def to_iiif
    iiif = attributes.clone
    iiif.delete('_id')
    iiif['within'] = iiif['manifests']
    iiif.delete('manifests')
    iiif
  end

end
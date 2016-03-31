class AnnotationLayer
  include Mongoid::Document
  store_in collection: "layers"

  field :@id, type: String
  field :@type, type: String, default: 'sc:Layer'
  field :label, type: String
  field :motivation, type: String
  field :description, type: String
  field :attribution, type: String
  field :license, type: String

  validates :@id, uniqueness: true

  def to_iiif
    iiif = attributes.clone
    iiif.delete('_id')
    iiif.delete('description') if description.nil? or description.empty?
    iiif.delete('attribution') if attribution.nil? or attribution.empty?
    iiif.delete('license') if license.nil? or license.empty?
    iiif.delete('motivation') if motivation.nil? or motivation.empty?
    iiif['@context'] = ["http://iiif.io/api/presentation/1/context.json"]
    iiif
  end

end

class AnnotationList
  include Mongoid::Document
  store_in collection: "lists"

  field :@id, type: String
  field :@type, type: String, default: 'sc:AnnotationList'
  field :label, type: String
  field :canvas, type: String
  field :project_id, type: String
  field :motivation, type: String
  field :layers, type: Array, default:[]

  validates :@id, uniqueness: true

  # @param [String] project ID
  # @param [String] canvas URI
  # @param [String] IIIF motivation
  # @param [String] display label
  # @return [AnnotationList]
  def self.find_or_create_list(project_id, canvas, other_attributes)
    motivation = other_attributes['motivation']
    label = other_attributes['label'] || 'Annotations'
    id = other_attributes['@id']
    # look for a useable list
    list = AnnotationList.where( { :project_id  => project_id, :canvas => canvas, :motivation => motivation} ).first

    # if no list, or if request specifies a new @id, create a list
    if (list.nil? || id)
      uuid = id || UUID.generate
      base_url = Rails.configuration.annotation_server.url
      base_url += '/' unless base_url.ends_with?('/')
      list_uri = "#{base_url}list/#{uuid}"

      list = AnnotationList.new(:@id => list_uri, canvas: canvas, project_id: project_id, motivation: motivation, label: label)
      list.layers = other_attributes['layers'] if other_attributes['layers'].class == Array
      list[:metadata] = other_attributes['metadata'] if  other_attributes['metadata'].class == Array
      list.id = uuid
      list.save
    end
    list
  end

  # @param [Array<String>] groups
  def annotations
    Annotation.where({'annotationList' => self['@id'], 'active' => true}).to_a
  end

  # @return [Integer]
  def find_next_sequence_in_list
    max =  Annotation.where(annotationList: self['@id']).max(:sequence)
    max = 1 if max.nil? or max == 0
    max
  end


  # @return [HASH] JSON-LD attributes
  def to_iiif
    iiif = attributes.clone
    iiif.delete('_id')
    iiif.delete('canvas')
    iiif.delete('project_id')
    iiif.delete('motivation') unless iiif['motivation']
    iiif['@context'] = ["http://iiif.io/api/presentation/1/context.json"]

    anno_layers = iiif.delete('layers')
    unless anno_layers.nil? or anno_layers.empty?
      iiif['within'] = Array.new
      anno_layers.each do |layer_id|
        annotation_layer = AnnotationLayer.where('@id' => layer_id).first
        iiif['within'].push annotation_layer.to_iiif
      end
    end
    iiif
  end

end

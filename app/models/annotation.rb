class Annotation
  include Mongoid::Document
  store_in collection: "annotations"

  field :@id, type: String
  field :@type, type: String
  field :on, type: String
  field :canvas, type: String
  field :manifest, type: String
  field :motivation, type: String
  field :resource, type: Hash
  field :annotationList, type: String
  field :sequence, type: Integer
  field :active, type: Boolean
  field :version, type: Integer
  field :permissions, type: Hash
  field :action, type: Hash
  field :annotatedBy, type: Hash

  attr_accessible :@id, :@type, :on, :canvas, :manifest, :motivation, :resource, :annotationList,
                  :sequence, :active, :version, :permissions, :action, :annotatedBy

  validates_presence_of :@id, :@type, :on, :canvas, :manifest, :motivation, :annotationList, :active, :permissions, :version, :resource

  # @param [User] user
  # @param [Array] read_groups
  # @param [AnnotationData] annotation_data
  # @param [AnnotationList] annotation_list
  def self.create_annotation(user, read_groups, annotation_data, annotation_list)
    Annotation.create({
        :@id => annotation_data.uri,
        :@type => 'oa:Annotation',
        :on =>  annotation_data.on,
        :manifest => annotation_data.manifest,
        :motivation => annotation_data.motivation,
        :resource => {
            :@type => 'cnt:ContentAsText',
            :language  => "en",
            :chars => annotation_data.text,
            :format => 'text/plain'
        },
        :annotationList => annotation_list['@id'],
        :sequence  => annotation_list.find_next_sequence_in_list,
        :active => true,
        :version => 1,
        :permissions => {
            :read => read_groups,
            :write => [ user.personal_group ]
        },
        :action => [
            {
                :event => "created",
                :agent => user.effective_uid,
                :date => Time.now()
            }
        ],
        :annotatedBy => {
            :@id => user.uri,
            :@type => 'prov:Agent',
            :name => "#{user.first_name} #{user.last_name}"
        },
    })
  end

  def on=(value)
    self[:on] = value
    canvas, selector = value.split('#xywh=')
    self[:canvas] = canvas
  end


  def to_iiif(context=true)
    anno = attributes.clone
    anno['@context'] = 'http://iiif.io/api/presentation/1/context.json' if context
    anno.delete('_id')
    anno.delete('src')
    anno.delete('shapes')
    anno.delete('manifest')
    anno.delete('permissions')
    anno.delete('annotationList')
    anno.delete('version')
    anno.delete('sequence')
    anno.delete('active')
    anno.delete('action')
    anno.delete('canvas')
    anno
  end

end
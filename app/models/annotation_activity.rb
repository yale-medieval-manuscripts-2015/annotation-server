class AnnotationActivity
  include Mongoid::Document
  store_in collection: "activity"

  field :activity_description, type: String
  field :annotation_uri, type: String
  field :canvas_uri, type: String
  field :manifest_uri, type: String
  field :canvas_label, type: String
  field :manifest_label, type: String
  field :project_id, type: String
  field :selector, type: String
  field :text, type: String
  field :permissions, type: Hash
  field :activity_time, type: Time
  field :user_email, type: String
  field :user_name, type: String
  field :user_id, type: String
  field :id_provider, type: String

  attr_accessible :activity_time, :user_email, :user_name, :user_id, :id_provider, :activity_description, :annotation_uri, :canvas_uri, :manifest_uri, :canvas_label, :manifest_label, :project_id, :selector, :text, :permissions

# @param [Array<String>] groups
# @param [Integer] limit_items
  def self.get_recent_activity(groups, limit_items)
    AnnotationActivity.in( 'permissions.read' => groups ).order_by(:activity_time.desc).limit(limit_items)
  end

# @param [User] user
# @param [String] activity_description
# @param [AnnotationData] annotation_data
# @param [Array<String>] read_groups
  def self.create_new(user, activity_description, annotation_data, read_groups)

     text = annotation_data.text || ''
     AnnotationActivity.create(
         {
             :user_name => user.name,
             :user_email => user.email,
             :user_id => user.effective_uid,
             :id_provider => user.effective_provider,
             :activity_description => activity_description,
             :activity_time => Time.now(),
             :annotation_uri => annotation_data.uri,
             :canvas_uri => annotation_data.canvas,
             :manifest_uri => annotation_data.manifest,
             :canvas_label => annotation_data.canvas_label,
             :manifest_label => annotation_data.manifest_label,
             :project_id => annotation_data.project_id,
             'selector' => annotation_data.selector,
             :text => text[0..30].gsub(/\s\w+\s*$/, '...'),
             :permissions => {
                 read: read_groups
              }
         }
     )
  end

  def gravatar_url
    email = user_email
    email = 'unknown@yale.edu' if email.nil?
    email.downcase!
    md5 = Digest::MD5.hexdigest(email)

    project = Project.where(:project_id => project_id).first
    default_image = project.thumbnailUrl

    "http://gravatar.com/avatar/#{md5}?s=64&d=#{default_image}"
  end

end
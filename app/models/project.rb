class Project
  include Mongoid::Document
  store_in collection: "projects"

  field :project_id, type: String
  field :name, type: String
  field :description, type: String
  field :thumbnailUrl, type: String
  field :permissions, type: Array
  field :groups, type: Array
  field :miradorConfiguration, type: Array

  attr_accessible :project_id, :name, :description, :thumbnailUrl, :permissions, :groups, :miradorConfiguration

end
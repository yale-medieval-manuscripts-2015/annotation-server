require 'rubygems'
require 'json'
require 'uuid'
require 'mongo'

include Mongo

class WelcomeController < ApplicationController

  def index
    groups = get_user_read_groups true
    @projects = find_projects groups
    @activity = AnnotationActivity.get_recent_activity(groups, 15)
  end

  # @return [Array<Project>]
  def find_projects groups
    projects = Project.in(permissions: groups).asc(:name)
    projects ||= []
    projects
  end
end

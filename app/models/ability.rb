class Ability
  include CanCan::Ability

  def initialize(user)

    if user.nil?
      user ||= User.new
    else
      default_groups = Rails.configuration.annotation_server.default_groups || []
      user.groups = user.groups + default_groups
    end

    can :read, Project do |project|
      user.groups.push("public") unless user.groups.include?("public")
      user_groups = user.groups + user.read_only_groups
      common_groups = project.permissions & user_groups
      !common_groups.nil? && !common_groups.empty?
    end

    can :write, Project do |project|
      user.groups.push("public") unless user.groups.include?("public")
      common_groups = project.permissions & user.groups
      !common_groups.nil? && !common_groups.empty?
    end

    can [:write, :delete], Annotation do |annotation|
      user.groups.push("public") unless user.groups.include?("public")
      common_groups = []
      if !annotation.permissions.nil? and annotation.permissions.has_key?('write')
        common_groups =  annotation.permissions['write'] & user.groups
      end
      !common_groups.nil? && !common_groups.empty?
    end

    can :read, Annotation do |annotation|
      user.groups.push("public") unless user.groups.include?("public")
      common_groups = []
      user_groups = user.groups + user.read_only_groups
      if !annotation.permissions.nil? and annotation.permissions.has_key?('read')
        common_groups =  annotation.permissions['read'] & user_groups
      end
      !common_groups.nil? && !common_groups.empty?
    end

    can :manage, Manifest do |manifest|
      user.manifest_admin? || false
    end

    can :show, Manifest do |manifest|
      able = true
      if !manifest.permissions.nil? and manifest.permissions.has_key?('read')
        user_groups = user.groups + user.read_only_groups
        common_groups =  manifest.permissions['read'] & user_groups
        able ||= !common_groups.nil? and !common_groups.empty?
      end
      able
    end

    can :manage, AnnotationLayer do |layer|
      user.manifest_admin? || false
    end

    can :manage, AnnotationList do |list|
      user.manifest_admin? || false
    end

  end

end

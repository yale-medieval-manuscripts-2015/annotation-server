class ApplicationController < ActionController::Base
  protect_from_forgery
  skip_before_filter :verify_authenticity_token, if: :json_request?

  respond_to :html, :json

  def get_user
    user = nil
    if user_signed_in?
      user = current_user
    end
    user
  end

  def get_user_read_groups(include_public_group)
    groups = []
    if user_signed_in?
      user = current_user
      unless user.nil?
        groups = user.groups || []
        read_only_groups = user.read_only_groups || []
        default_groups = Rails.configuration.annotation_server.default_groups || []
        groups = groups + default_groups + read_only_groups
      end
    end
    groups.append 'public' if include_public_group
    groups
  end

  def json_request?
    request.format.json?
  end

end

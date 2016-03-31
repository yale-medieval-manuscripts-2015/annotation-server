class RegistrationsController < Devise::RegistrationsController
  after_filter :add_account

  protected

  def add_account
    if resource.persisted? && resource.provider != 'cas' # user is created successfuly
      user = resource
      user.provider = 'email'
      user.personal_group = "#{user.provider}/#{user.effective_uid}"
      user.name = "#{user.first_name} #{user.last_name}"
      user.groups.append(user.personal_group)
      user.save
    end
  end

  # By default we want to require a password checks on update.
  # You can overwrite this method in your own RegistrationsController.
  def update_resource(resource, params)
    if signed_in? && resource.provider == 'cas' && current_user.provider == 'cas' && current_user.uid = resource.uid
      p params
      resource.first_name = params[:first_name]
      resource.last_name = params[:last_name]
      resource.name = "#{resource.first_name} #{resource.last_name}"
      resource.email = params[:email]
      resource.save
    else
      resource.update_with_password(params)
    end
  end


  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :first_name, :last_name) }
  end

end
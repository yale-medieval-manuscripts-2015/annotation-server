class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def cas
    auth = request.env["omniauth.auth"]
    @user = User.where(:provider => auth.provider, :uid => auth.uid).first
    user_is_new = false
    unless @user

      first_name = ''
      last_name, name = auth.uid
      email = "#{auth.uid}@example.org"

      if Rails.configuration.annotation_server.use_ldap
        directory_info = ldap_attributes(auth.uid)
        unless directory_info.nil?
          first_name = directory_info.givenname[0] unless directory_info.givenname.nil? || directory_info.givenname.empty?
          last_name = directory_info.sn[0] unless directory_info.sn.nil? || directory_info.sn.empty?
          name = directory_info.cn[0] unless directory_info.cn.nil? || directory_info.cn.empty?
          email = directory_info.mail[0] unless directory_info.mail.nil? || directory_info.mail.empty?
        end
      end

      @user = User.create(
          provider: auth.provider,
          uid: auth.uid,
          email: email,
          password: Devise.friendly_token[0,20],
          personal_group: "#{auth.provider}/#{auth.uid}",
          groups: [ "#{auth.provider}/#{auth.uid}"  ],
          first_name: first_name,
          last_name: last_name,
          name: name
      )

      user_is_new = true
    end

    if @user
      if Rails.configuration.annotation_server.use_ldap || !user_is_new
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => "CAS") if is_navigational_format?
      else
        sign_in @user
        #sign_in_and_redirect @user, :event => :authentication # TODO: CAS-friendly user edit page
        set_flash_message(:notice, :success, :kind => "CAS") if is_navigational_format?
        flash[:alert] = "Please provide your name and first.last@example.org email address"
        redirect_to edit_user_registration_url
      end
    else
      redirect_to new_user_registration_url
    end
  end

  def ldap_attributes uid
    ldap = Net::LDAP.new host: Rails.configuration.annotation_server.ldap_host,
                         port: Rails.configuration.annotation_server.ldap_port
    filter = Net::LDAP::Filter.eq("uid", uid)
    treebase = "o=example.org"
    entries = ldap.search(:base => treebase, :filter => filter)
    return entries[0] unless entries.empty?
    nil
  end



end

class User
  include Mongoid::Document
  store_in collection: "users"

  # Admin
  field :manifest_admin, type: Boolean

  # Application-specific properties
  field :first_name, type: String
  field :last_name, type: String
  field :personalGroup, as: :personal_group,  type: String
  field :groups, type: Array, default: []
  field :read_only_groups, type: Array, default: []

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # removed :registerable until we have a need
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:cas]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :personal_group, :groups, :email, :password, :password_confirmation, :remember_me

  # Omniauth
  attr_accessible :provider, :uid, :name
  field :provider,        type: String, default: ""
  field :uid,             type: String, default: ""
  field :name,            type: String, default: ""

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  def effective_uid
    return uid unless uid.nil? || uid.empty?
    return email
  end

  def effective_provider
    return provider
  end

  def uri
    base_url = Rails.configuration.annotation_server.url
    base_url += '/' unless base_url.ends_with?('/')
    return "#{base_url}user/#{id}"
  end

end

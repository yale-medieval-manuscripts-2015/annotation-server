source 'https://rubygems.org'


gem 'unicorn'

gem 'rails', '3.2.16'
gem 'sass-rails',   '>= 3.2'
gem 'bootstrap-sass', '3.1.1.0'
gem 'jquery-rails'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#gem 'sqlite3'
gem 'mongo'
gem 'mongoid', '~> 3.1.6'
gem 'uuid'
gem 'devise'

gem 'omniauth'
gem 'omniauth-cas'
gem 'cancan'
gem 'bson_ext'
gem 'net-ldap'
gem 'rack-cors', :require => 'rack/cors'
#gem 'annotation_solr_loader', :path => "~/rails_projects/annotation_solr_loader/"
gem 'annotation_solr_loader', github: 'ydc2/annotation-solr-loader', tag: 'v1.4'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.2.1'


  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem 'factory_girl_rails', '~> 4.2.0'
  gem 'rspec-rails', '~> 2.13.1'
  gem 'spork-rails'
  gem 'selenium-webdriver', '2.35.1'
  gem 'capybara', '2.1.0'
  gem 'database_cleaner'
end

# Gems to handle delayed_job background processing
  gem 'delayed_job'
  gem 'delayed_job_mongoid'

  gem 'rsolr'
# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

# This gemfile provides additional gems for testing and releasing this cookbook
# It is meant to be installed on top of ChefDK which provides the majority
# of the necessary gems for testing this cookbook
#
# Run 'chef exec bundle install' to install these dependencies

source 'https://rubygems.org'

gem 'community_cookbook_releaser'
gem 'chef', '>= 12.5.1'

group :test do
  gem 'rake', '>= 11.3'
  gem 'berkshelf', '>= 5.0'
  gem 'chefspec',  '>= 5.2'
  gem 'coveralls', '~> 0.8.2', require: false
  gem 'rb-readline'
end

group :integration do
  gem 'test-kitchen'
  gem 'kitchen-inspec'
  gem 'kitchen-vagrant'
  gem 'winrm-elevated'
end

group :release do
  gem 'stove'
end
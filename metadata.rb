name 'iis'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license 'Apache-2.0'
description 'Installs/Configures Microsoft Internet Information Services'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '7.2.0'
supports 'windows'
depends 'windows', '>= 4.1.0'
source_url 'https://github.com/chef-cookbooks/iis'
issues_url 'https://github.com/chef-cookbooks/iis/issues'
chef_version '>= 12.14' if respond_to?(:chef_version)

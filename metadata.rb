name 'iis'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license 'Apache 2.0'
description 'Installs/Configures Microsoft Internet Information Services'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '4.1.6'
supports 'windows'
depends 'windows', '>= 1.34.6'
source_url 'https://github.com/chef-cookbooks/iis' if respond_to?(:source_url)
issues_url 'https://github.com/chef-cookbooks/iis/issues' if respond_to?(:issues_url)

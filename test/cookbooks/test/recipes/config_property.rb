#
# Cookbook:: test
# Recipe:: config_property
#
# copyright: 2017, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe 'iis'

# create and start a new site that maps to
# the physical location C:\inetpub\wwwroot\testfu
# first the physical location must exist
directory "#{node['iis']['docroot']}/ConfigSite" do
  action :create
end

# now create and start the site (note this will use the default application pool which must exist)
iis_site 'ConfigSite' do
  protocol :http
  port 8080
  path "#{node['iis']['docroot']}/ConfigSite"
  action [:add, :start]
end

# Sets up logging
iis_config_property 'directory' do
  ps_path   'MACHINE/WEBROOT/APPHOST'
  filter    'system.applicationHost/sites/siteDefaults/logfile'
  value     'D:\\logs'
end

# Increase file upload size for 'ConfigSite'
iis_config_property 'maxAllowedContentLength' do
  ps_path   'MACHINE/WEBROOT/APPHOST/ConfigSite'
  filter    'system.webServer/security/requestFiltering/requestLimits'
  value     50_000_000
end

# Set XSS-Protection header on all sites
iis_config_property 'Add X-Xss-Protection' do
  ps_path   'MACHINE/WEBROOT/APPHOST'
  filter    'system.webServer/httpProtocol/customHeaders'
  property  'name'
  value     'X-Xss-Protection'
  action    :add
end
iis_config_property 'Set X-Xss-Protection' do
  ps_path   'MACHINE/WEBROOT/APPHOST'
  filter    "system.webServer/httpProtocol/customHeaders/add[@name='X-Xss-Protection']"
  property  'value'
  value     '1; mode=block'
end

# Add environment variable + value
iis_config_property 'Add login/ASPNETCORE_ENVIRONMENT' do
  ps_path           'MACHINE/WEBROOT/APPHOST'
  location          'Default Web site'
  filter            'system.webServer/aspNetCore/environmentVariables'
  property          'name'
  value             'ASPNETCORE_ENVIRONMENT'
  extra_add_values  value: 'Test'
  action            :add
end

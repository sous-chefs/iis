#
# Cookbook:: test
# Recipe:: config
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
directory "#{node['iis']['docroot']}/MySite" do
  action :create
end

# now create and start the site (note this will use the default application pool which must exist)
iis_site 'MySite' do
  protocol :http
  port 8080
  path "#{node['iis']['docroot']}/MySite"
  action [:add, :start]
end

# Sets up logging
iis_psconfig_key 'config logs' do
  filter 'system.applicationHost/sites/siteDefaults/logFile'
  key 'directory'
  value 'D:\logs'
  action :set
end

iis_psconfig_key 'Disable 29 hour app pool recycle' do
  filter 'system.applicationHost/applicationPools/applicationPoolDefaults/recycling/periodicRestart'
  key 'time'
  value '00:00:00'
  action :set
end

# Increase file upload size for 'MySite'
iis_psconfig_key '"MySite" /section:system.webServer/security/requestFiltering /requestLimits.maxAllowedContentLength:50000000' do
  pspath 'MACHINE/WEBROOT/APPHOST/MySite'
  filter 'system.webServer/security/requestFiltering/requestLimits'
  key 'maxAllowedContentLength'
  value 50000000
  action :set
end

# Test a single value
iis_psconfig_collection 'system.applicationHost/applicationPools/applicationPoolDefaults/recycling/periodicRestart/schedule' do
  pspath 'MACHINE/WEBROOT/APPHOST'
  filter 'system.applicationHost/applicationPools/applicationPoolDefaults/recycling/periodicRestart/schedule'
  value ['06:00:00', '07:00:00']
  action :set
end

# Test multiple values

# lock/unlock
#
# Cookbook:: test
# Recipe:: site
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
include_recipe 'iis::mod_ftp'

directory "#{node['iis']['docroot']}\\site_test" do
  recursive true
end

directory "#{node['iis']['docroot']}\\site_test2" do
  recursive true
end

directory "#{node['iis']['docroot']}\\ftp_site_test" do
  recursive true
end

iis_site 'add/start to_be_deleted' do
  site_name 'to_be_deleted'
  application_pool 'DefaultAppPool'
  path "#{node['iis']['docroot']}/site_test"
  host_header 'localhost'
  port 8081
  action [:add, :start]
end

iis_site 'test' do
  application_pool 'DefaultAppPool'
  path "#{node['iis']['docroot']}/site_test"
  host_header 'localhost'
  action [:add, :start]
end

iis_site 'restart to_be_deleted' do
  site_name 'to_be_deleted'
  action [:restart]
end

iis_site 'test2' do
  application_pool 'DefaultAppPool'
  path "#{node['iis']['docroot']}/site_test2"
  host_header 'localhost'
  port 8080
  action [:add, :start]
end

iis_site 'stop/delete to_be_deleted' do
  site_name 'to_be_deleted'
  action [:stop, :delete]
end

iis_site 'myftpsite' do
  path "#{node['iis']['docroot']}\\ftp_site_test"
  application_pool 'DefaultAppPool'
  bindings 'ftp/*:21:*'
  action [:add, :config]
end

directory "#{node['iis']['docroot']}\\mytest" do
  action :create
end

iis_site 'add/start MyTest' do
  site_name 'MyTest'
  protocol :http
  port 8090
  path "#{node['iis']['docroot']}\\mytest"
  action [:add, :start]
end

iis_app 'MyTest' do
  path '/testpool'
  application_pool 'Test AppPool'
  physical_path "#{node['iis']['docroot']}\\mytest"
  enabled_protocols 'http'
  action :add
end

iis_site 'config MyTest' do
  site_name 'MyTest'
  protocol :http
  port 8090
  path "#{node['iis']['docroot']}\\mytest"
  action :config
end

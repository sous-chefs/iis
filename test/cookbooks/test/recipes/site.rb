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

iis_site 'to_be_deleted' do
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

iis_site 'to_be_deleted' do
  action [:restart]
end

iis_site 'test2' do
  application_pool 'DefaultAppPool'
  path "#{node['iis']['docroot']}/site_test2"
  host_header 'localhost'
  port 8080
  action [:add, :start]
end

iis_site 'to_be_deleted' do
  action [:stop, :delete]
end

iis_site 'myftpsite' do
  path "#{node['iis']['docroot']}\\ftp_site_test"
  application_pool 'DefaultAppPool'
  bindings 'ftp/*:21:*'
  action [:add, :config]
end

#
# Cookbook:: test
# Recipe:: vdir
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

directory node['iis']['docroot'].to_s do
  recursive true
end

directory "#{node['iis']['docroot']}\\vdir_test" do
  recursive true
end

directory "#{node['iis']['docroot']}\\foo" do
  recursive true
end

directory "#{node['iis']['docroot']}\\app_test" do
  recursive true
end

directory "#{node['iis']['docroot']}\\app_test\\vdir_test2" do
  recursive true
end

iis_pool 'DefaultAppPool' do
  pipeline_mode :Classic
  action :add
end

iis_site 'Default Web Site' do
  protocol :http
  port 80
  path node['iis']['docroot'].to_s
  action [:add, :start]
end

iis_app 'Default Web Site' do
  path '/app_test'
  application_pool 'DefaultAppPool'
  physical_path "#{node['iis']['docroot']}/app_test"
  enabled_protocols 'http,net.pipe'
  action [:add, :config]
end

iis_vdir 'Default Web Site/' do
  path '/vdir_test'
  physical_path "#{node['iis']['docroot']}\\vdir_test"
  username 'vagrant'
  password 'vagrant'
  logon_method :ClearText
  allow_sub_dir_config false
  action [:add, :config]
end

iis_vdir 'Creating vDir /foo for Sitename' do
  application_name 'Default Web Site'
  path '/foo'
  physical_path "#{node['iis']['docroot']}\\foo"
  action [:add, :config]
end

iis_vdir 'Creating vDir /vdir_test2 in app' do
  application_name 'Default Web Site/app_test'
  path '/vdir_test2'
  physical_path "#{node['iis']['docroot']}\\app_test\\vdir_test2"
  action [:add, :config]
end

iis_vdir 'Default Web Site/' do
  path '/vdir_test'
  physical_path "#{node['iis']['docroot']}\\vdir_test"
  username 'vagrant'
  password 'vagrant'
  logon_method :ClearText
  allow_sub_dir_config false
  action [:add, :config]
end

#
# Cookbook:: test
# Recipe:: module
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

directory "#{node['iis']['docroot']}\\v1_1" do
  recursive true
end

iis_app 'Default Web Site' do
  path '/v1_1'
  application_pool 'DefaultAppPool'
  physical_path "#{node['iis']['docroot']}/v1_1"
  enabled_protocols 'http,net.pipe'
  action :add
end

iis_module 'example module' do
  application 'Default Web Site/v1_1'
  type 'System.Web.Handlers.ScriptModule, System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35'
  precondition 'managedHandler'
  action :add
end

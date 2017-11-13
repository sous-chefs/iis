#
# Cookbook:: test
# Recipe:: pool
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

directory "#{node['iis']['docroot']}\\test" do
  recursive true
end

# creates a new app pool
iis_pool 'myAppPool_v1_1' do
  runtime_version '2.0'
  pipeline_mode :Classic
  action [:add, :config, :stop]
end

iis_pool 'test_start' do
  pipeline_mode :Classic
  action [:add, :config, :stop]
end

iis_pool 'testapppool' do
  thirty_two_bit false
  runtime_version '4.0'
  pipeline_mode :Integrated
  start_mode :OnDemand
  identity_type :SpecificUser
  periodic_restart_schedule ['06:00:00', '14:00:00', '17:00:00']
  username "#{node['hostname']}\\vagrant"
  password 'vagrant'
  action [:add, :config]
end

iis_pool 'test_start' do
  action [:start]
end

iis_pool 'My App Pool' do
  runtime_version '4.0.30319'
  thirty_two_bit true
  pipeline_mode :Integrated
  action [:add, :config, :start]
end

iis_pool 'test_identity_type' do
  identity_type :NetworkService
  action [:add, :config, :start]
end

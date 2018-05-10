#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Cookbook:: iis
# Recipe:: default
#
# Copyright:: 2011-2016, Chef Software, Inc.
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
#
# Install base IIS in powershell mode until chef client 14, because -
# a. Default install mode for windows_feature is dism in chef-client 13
# b. Dism feature for IIS is not always enabled at startup.
# After IIS install, other auxiliary features are enabled for installation,
# so they can continue to use dism.
# Base IIS feature in powershell mode is always "Web-Server".
# Always add this, so that we don't require this to be added if we want to add other components
default = 'Web-Server'

windows_feature default do
  action :install
  all !Opscode::IIS::Helper.older_than_windows2012?
  source node['iis']['source'] unless node['iis']['source'].nil?
  install_method :windows_feature_powershell
end

if node['iis']['components']
  node['iis']['components'].each do |feature|
    windows_feature feature do
      action :install
      all !Opscode::IIS::Helper.older_than_windows2012?
      source node['iis']['source'] unless node['iis']['source'].nil?
    end
  end
end

service 'iis' do
  service_name 'W3SVC'
  action [:enable, :start]
end

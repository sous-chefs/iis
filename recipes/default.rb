#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: iis
# Recipe:: default
#
# Copyright 2011, Opscode, Inc.
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

include_recipe "webpi"

unless node['iis']['accept_eula'] then
  Chef::Application.fatal!("You must accept the EULA by setting the attribute node['iis']['accept_eula'] before installing IIS.")
end

webpi_product node['iis']['components'] do
  accept_eula node['iis']['accept_eula']
  action :install
  notifies :run, "execute[Register ASP.NET v4]", :immediately
  notifies :run, "execute[Register ASP.NET v4 (x64)]", :immediately
end

aspnet_regiis = "#{ENV['WinDir']}\\Microsoft.NET\\Framework\\v4.0.30319\\aspnet_regiis.exe"
execute 'Register ASP.NET v4' do
  command "#{aspnet_regiis} -i"
  only_if { File.exists?(aspnet_regiis) }
  action :nothing
end

aspnet_regiis64 = "#{ENV['WinDir']}\\Microsoft.NET\\Framework64\\v4.0.30319\\aspnet_regiis.exe"
execute 'Register ASP.NET v4 (x64)' do
  command "#{aspnet_regiis64} -i"
  only_if { File.exists?(aspnet_regiis64) }
  action :nothing
end

service "iis" do
  service_name "W3SVC"
  action :nothing
end

#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: iis
# Recipe:: mod_install_arr
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

#Check for x64
if node[:kernel][:machine] == "x86_64"
  externalCache = "http://download.microsoft.com/download/3/4/1/3415F3F9-5698-44FE-A072-D4AF09728390/ExternalDiskCache_amd64_en-US.msi"
  webFarm = "http://download.microsoft.com/download/3/4/1/3415F3F9-5698-44FE-A072-D4AF09728390/webfarm_amd64_en-US.msi"
  requestRouter = "http://download.microsoft.com/download/6/3/D/63D67918-483E-4507-939D-7F8C077F889E/requestRouter_x64.msi"
  arrRewrite = "http://download.microsoft.com/download/6/7/D/67D80164-7DD0-48AF-86E3-DE7A182D6815/rewrite_amd64_en-US.msi"
else
  externalCache = "http://download.microsoft.com/download/4/D/F/4DFDA851-515F-474E-BA7A-5802B3C95101/ExternalDiskCache_x86_en-US.msi"
  webFarm = "http://download.microsoft.com/download/5/7/0/57065640-4665-4980-A2F1-4D5940B577B0/webfarm_v1.1_amd64_en_US.msi"
  requestRouter = "http://download.microsoft.com/download/6/3/D/63D67918-483E-4507-939D-7F8C077F889E/requestRouter_x86.msi"
  arrRewrite = "http://download.microsoft.com/download/6/9/C/69C1195A-123E-4BE8-8EDF-371CDCA4EC6C/rewrite_x86_en-US.msi"
end

#Stop IIS WAS
windows_batch "Stop IIS" do
  code <<-EOH
  net stop was /y
  EOH
  action :run
end

################################
### Install ARR ################
################################

#Install x64 External Disk Cache
windows_package 'External Disk Cache ARR' do
  source externalCache
  installer_type :msi
  action :install
end

#Install x64 Web Farm
windows_package 'Web Farm ARR' do
  source webFarm
  installer_type :msi
  action :install
end

#Install x64 Request Router
windows_package 'Request Router ARR' do
  source requestRouter
  installer_type :msi
  action :install
end

#Install x64 Rewrite 
windows_package 'Rewrite ARR' do
  source arrRewrite
  installer_type :msi
  action :install
end

#Start IIS WAS
windows_batch "Start IIS WAS" do
  code <<-EOH
  net start was /y
  EOH
  action :run
end

#Start IIS W3SVC
windows_batch "Start IIS" do
  code <<-EOH
  net start w3svc /y
  EOH
  action :run
end
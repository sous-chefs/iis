#
# Author:: Blair Hamilton (<blairham@me.com>)
# Cookbook:: iis
# Recipe:: mod_aspnet45
#
# Copyright:: 2011-2019, Chef Software, Inc.
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

iis_install 'install IIS, ASPNET45' do
  additional_components %w(NetFx4Extended-ASPNET45 IIS-NetFxExtensibility45 IIS-ASPNET45)
  source node['iis']['source']
  install_method node['iis']['windows_feature_install_method']
  start_iis true
end

include_recipe 'iis::mod_isapi'

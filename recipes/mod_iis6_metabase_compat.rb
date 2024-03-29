#
# Author:: Kristian Vlaardingerbroek (<kvlaardingerbroek@schubergphilis.com>)
# Cookbook:: iis
# Recipe:: mod_iis6_metabase_compat
#
# Copyright:: 2013-2016, Schuberg Philis B.V.
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

iis_install 'install IIS, Compatability, Metabase' do
  additional_components %w(IIS-IIS6ManagementCompatibility IIS-Metabase)
  source node['iis']['source']
  install_method node['iis']['windows_feature_install_method']
  start_iis true
end

#
# Cookbook:: iis
# Resource:: install
#
# Copyright:: 2018-2019, Chef Software, Inc.
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

include IISCookbook::Helper
include IISCookbook::WindowsFeatureHelper

property :source, String
property :additional_components, Array, default: []
property :install_method, Symbol, required: false, equal_to: [:windows_feature_dism, :windows_feature_powershell, :windows_feature_servermanagercmd], default: :windows_feature_dism

action :install do
  features_to_install = transform_feature_name(new_resource.install_method, ['IIS-WebServerRole'].concat(new_resource.additional_components))

  windows_feature 'Install IIS and additional components' do
    feature_name features_to_install
    action :install
    all !IISCookbook::Helper.older_than_windows2012?
    source new_resource.source unless new_resource.source.nil?
    install_method new_resource.install_method
  end
end

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

property :source, String
property :additional_components, [Array, String],
 coerce: proc { |c| Array(c) },
 default: []
property :install_method, [String, Symbol],
  required: false,
  coerce: proc { |i| i.to_sym },
  equal_to: [:windows_feature_dism, :windows_feature_powershell, :windows_feature_servermanagercmd],
  default: :windows_feature_dism
property :start_iis, [true, false], default: false

action :install do
  features = ['IIS-WebServerRole'].concat(new_resource.additional_components)

  features_to_install = if new_resource.install_method == :windows_feature_powershell
                          powershell_feature_name(features)
                        else
                          features
                        end

  windows_feature 'Install IIS and additional components' do
    feature_name features_to_install
    action :install
    all !IISCookbook::Helper.older_than_windows2012?
    source new_resource.source unless new_resource.source.nil?
    install_method new_resource.install_method
  end

  service 'iis' do
    service_name 'W3SVC'
    action [:enable, :start]
    only_if { new_resource.start_iis }
  end
end

action_class do
  def powershell_feature_name(names)
    Array(names).map do |name|
      # This will search for the powershell format (Name) of the feature name, by the both the install name or Name, meaning
      # that it doesnt care if you pass the powershell format or dism format, it will return the powershell format
      cmd = "Get-WindowsFeature | Where-Object {$_.AdditionalInfo.InstallName -Eq '#{name}' -or $_.Name -eq '#{name}'} | Select -Expand Name"
      result = powershell_out cmd
      if result.stderr.to_s.empty?
        next result.stdout.strip
      else
        Chef::Log.error(result.stderr)
        raise "Unable to translate feature #{name}"
      end
    end
  end
end

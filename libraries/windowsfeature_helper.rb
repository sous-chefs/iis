#
# Cookbook:: iis
# Library:: windowsfeature_helper
#
# Copyright:: 2017-2021, Chef Software, Inc.
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

module IISCookbook
  module WindowsFeatureHelper
    def transform_feature_name(install_method, names)
      if install_method.to_sym == :windows_feature_powershell
        Array(names).map do |name|
          cmd = "Get-WindowsFeature | Where-Object {$_.AdditionalInfo.InstallName -Eq '#{name}' -or $_.Name -eq '#{name}'} | Select -Expand Name"
          result = powershell_out cmd
          if result.stderr.empty?
            next result.stdout.strip
          else
            Chef::Log.warn("Unable to translate feature #{name}")
            Chef::Log.warn(result.stderr)
            next name
          end
        end
      else
        names
      end
    end
  end
end

::Chef::DSL::Recipe.include(IISCookbook::WindowsFeatureHelper)

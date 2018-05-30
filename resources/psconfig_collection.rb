#
# Cookbook:: iis
# Resource:: config
#
# Copyright:: 2017, Chef Software, Inc.
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

include Opscode::IIS::Helper

property :filter, String, desired_state: false
property :pspath, String, default: 'MACHINE/WEBROOT/APPHOST', desired_state: false
property :value, [Array, String], coerce: proc { |v| [*v].sort }

action :set do
  converge_if_changed do
    # Remove the values that are no longer required
    ([*current_resource.value] - [*new_resource.value]).each do |current_value|
      remove_cmd = "Remove-WebConfigurationProperty -PSPath '#{new_resource.pspath}' -Filter '#{new_resource.filter}' -name '.' -AtElement @{value='#{current_value}'}"
      Chef::Log.debug("Removing config collection value via #{remove_cmd}")
      powershell_out!(remove_cmd)
    end

    # Add the new values
    ([*new_resource.value] - [*current_resource.value]).each do |current_value|
      add_cmd = "Add-WebConfigurationProperty -PSPath '#{new_resource.pspath}' -Filter '#{new_resource.filter}' -name '.' -Value @{value='#{current_value}'}"
      Chef::Log.debug("Adding config collection value via #{add_cmd}")
      powershell_out!(add_cmd)
    end
  end
end

load_current_value do |desired|
  # if the value is a timespan, convert it to a string
  config_cmd = "ConvertTo-Json -InputObject @(Get-WebConfigurationProperty -PSPath '#{desired.pspath}' -Filter '#{desired.filter}' -Name '.' | Select-Object -ExpandProperty Collection | Select-Object -ExpandProperty 'Value' | ForEach-Object{if($_.GetType().FullName -eq 'System.TimeSpan'){$_.ToString()}else{$_.Value}}) -Compress"

  Chef::Log.debug("Retrieving config state by running #{config_cmd}")
  ps_results = powershell_out(config_cmd)

  # detect a failure without raising and then set current_resource to nil
  if ps_results.error?
    Chef::Log.debug("Error fetching config state: #{ps_results.stderr}")
    current_value_does_not_exist!
  end

  Chef::Log.debug("The results were #{ps_results.stdout}")
  results = Chef::JSONCompat.from_json(ps_results.stdout)

  value results
end

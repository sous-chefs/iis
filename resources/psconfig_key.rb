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
property :key, String, desired_state: false
property :value, [String, Integer]

action :set do
  converge_if_changed do
    config_cmd = if new_resource.value.is_a? Integer
                   "Set-WebConfigurationProperty -PSPath '#{new_resource.pspath}' -Filter '#{new_resource.filter}' -Name '#{new_resource.key}' -Value #{new_resource.value}"
                 else
                   "Set-WebConfigurationProperty -PSPath '#{new_resource.pspath}' -Filter '#{new_resource.filter}' -Name '#{new_resource.key}' -Value '#{new_resource.value}'"
                 end

    Chef::Log.info("Setting config state by running #{config_cmd}")
    powershell_out!(config_cmd)
  end
end

load_current_value do |desired|
  # if the value is a timespan, convert it to a string
  config_cmd = "Get-WebConfigurationProperty -PSPath '#{desired.pspath}' -Filter '#{desired.filter}' -Name '#{desired.key}' | Select-Object -Property @{Name='Value'; Expression = {if($_.Value.GetType().FullName -eq 'System.TimeSpan'){$_.Value.ToString()}else{$_.Value}}} | ConvertTo-Json -Compress"

  Chef::Log.info("Retrieving config state by running #{config_cmd}")
  ps_results = powershell_out(config_cmd)

  # detect a failure without raising and then set current_resource to nil
  if ps_results.error?
    Chef::Log.info("Error fetching config state: #{ps_results.stderr}")
    current_value_does_not_exist!
  end

  Chef::Log.info("The results were #{ps_results.stdout}")
  results = Chef::JSONCompat.from_json(ps_results.stdout)

  value results['Value']
end

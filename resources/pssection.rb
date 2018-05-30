#
# Cookbook:: iis
# Resource:: section
#
# Copyright:: 2016-2017, Chef Software, Inc.
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
include Opscode::IIS::Processors

property :filter, String, name_property: true
property :pspath, String, default: 'MACHINE/WEBROOT/APPHOST', desired_state: false
property :location, String
property :locked, String
# ? Maybe add an alias for section to filter?

action :unlock do
  if current_resource.locked != 'false'
    converge_by "Unlocking the section - \"#{new_resource}\"" do
      section_cmd = "Remove-WebConfigurationLock -PSPath '#{new_resource.pspath}' -Filter '#{new_resource.filter}'"
      section_cmd << " -Location '#{new_resource.location}'" if new_resource.location

      Chef::Log.debug("Unlocking section by running #{section_cmd}")
      powershell_out!(section_cmd)
    end
  else
    Chef::Log.debug("#{new_resource} already unlocked - nothing to do")
  end
end

action :lock do
  if current_resource.locked != 'true'
    converge_by "Locking the section - \"#{new_resource}\"" do
      section_cmd = "Add-WebConfigurationLock -Type 'General' -PSPath '#{new_resource.pspath}' -Filter '#{new_resource.filter}'"
      section_cmd << " -Location '#{new_resource.location}'" if new_resource.location

      Chef::Log.debug("Locking section by running #{section_cmd}")
      powershell_out!(section_cmd)
    end
  else
    Chef::Log.debug("#{new_resource} already locked - nothing to do")
  end
end

load_current_value do |desired|
  section_cmd = "Get-WebConfigurationLock -PSPath '#{desired.pspath}' -Filter '#{desired.filter}'"
  section_cmd << " -Location '#{desired.location}'" if desired.location
  section_cmd << " | Where-Object {$_.LockType -eq 'lockItem'} | Select-Object -Property LockType,Value,PSPath,Location| ConvertTo-Json -Compress"

  # ! When an item is locked, I see a 'lockItem' and 'overrideMode' value in the LockType, do we need to be able to handle both scenarios?
  Chef::Log.debug("Retrieving section lock state by running #{section_cmd}")
  ps_results = powershell_out(section_cmd)

  # detect a failure without raising and then set current_resource to nil
  if ps_results.error?
    Chef::Log.debug("Error fetching section lock state: #{ps_results.stderr}")
    current_value_does_not_exist!
  end

  Chef::Log.debug("The results were #{ps_results.stdout}")

  if ps_results.stdout.empty?
    locked 'false'
  else
    results = Chef::JSONCompat.from_json(ps_results.stdout)
    #locked results['Value'].to_s
    locked results['Value'].to_s
  end
end

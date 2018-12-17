#
# Author:: Jason Field
# Cookbook Name:: iis
# Resource:: manager_permissions
#
# Copyright:: 2018, Calastone Ltd.
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
# Grants access to IIS manager against a site or application

property :config_path,  String, name_property: true
property :users,        Array,  default: []
property :groups,       Array,  default: []

action :config do
  # This only works on 2016 + servers, Server 2012r2 does not dispose
  # of com objects when called from a cmd style script for IIS User
  # https://serverfault.com/questions/587305/powershell-has-stopped-working-on-ps-exit-after-creating-iis-user
  if node['os_version'].to_f < 10.0
    Chef::Log.warn('IIS Manager Permission requires Windows 2016 or newer, Skipping')
    return
  end
  # user permissions are accessed by .Net API
  all_users = (new_resource.users + new_resource.groups).map { |i| "\"#{i}\"" }.join ','

  unless new_resource.users.count == 0
    set_users = <<-EOH
    foreach ($principal in #{new_resource.users.map { |i| "\"#{i}\"" }.join ','})
    {
      if (($current | Where-Object { $_.Name -eq $principal -and -not $_.IsRole }) -eq $null)
      {
        [Microsoft.Web.Management.Server.ManagementAuthorization]::Grant($principal, "#{new_resource.config_path}", $false)
      }
    }
    EOH
  end

  unless new_resource.groups.count == 0
    set_groups = <<-EOH
    foreach ($principal in #{new_resource.groups.map { |i| "\"#{i}\"" }.join ','})
    {
      if (($current | Where-Object { $_.Name -eq $principal -and $_.IsRole }) -eq $null)
      {
        [Microsoft.Web.Management.Server.ManagementAuthorization]::Grant($principal, "#{new_resource.config_path}", $true)
      }
    }
    EOH
  end

  powershell_script "Set permissions for Path #{new_resource.config_path}" do
    code <<-EOH
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Management") | Out-Null
    $current = [Microsoft.Web.Management.Server.ManagementAuthorization]::GetAuthorizedUsers("#{new_resource.config_path}", $false, 0, 1000)

    #{set_users}
    #{set_groups}

    # Delete entries not in current definition
    $current | Where-Object { $_.Name -notin #{all_users} } | `
      Foreach-Object { [Microsoft.Web.Management.Server.ManagementAuthorization]::Revoke($_.Name, "#{new_resource.config_path}") }
    EOH
    only_if <<-EOH
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Management") | Out-Null
    $current = [Microsoft.Web.Management.Server.ManagementAuthorization]::GetAuthorizedUsers("#{new_resource.config_path}", $false, 0, 1000)
    $current.Count -ne #{new_resource.users.count + new_resource.groups.count} -or ($current | Where-Object { $_.Name -in #{all_users} }).Count -ne #{new_resource.users.count + new_resource.groups.count}
    EOH
    notifies :restart, 'service[WMSVC]', :delayed
  end

  service 'WMSVC' do
    action :nothing
  end
end

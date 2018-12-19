#
# Cookbook Name:: iis
# Resource:: config_property
#
# Copyright 2018, Calastone Ltd.
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
# Configures an IIS property (using powershell for idempotence)

property :property, String, name_property: true
property :ps_path, String, required: true
property :location, String
property :filter, String, required: true
property :value, [String, Integer], required: true

action :set do
  location_param = "-location \"#{new_resource.location}\"" if
    property_is_set?(:location)

  # powershell doesn't like { or } in xpath values (e.g. server variables)
  escaped_filter = new_resource.filter.gsub('{', '{{').gsub('}', '}}')

  property_value =  if new_resource.value.is_a?(Integer)
                      new_resource.value.to_s
                    else
                      "\"#{new_resource.value}\""
                    end
  powershell_script "Set #{new_resource.ps_path}#{new_resource.location}\
/#{escaped_filter}/#{new_resource.property}" do
    code <<-EOH
    Set-WebConfigurationProperty -pspath "#{new_resource.ps_path}" \
    #{location_param} -filter "#{escaped_filter}" \
    -name "#{new_resource.property}" \
    -value #{property_value} -ErrorAction Stop
    EOH
    only_if <<-EOH
    (Get-WebConfigurationProperty -pspath "#{new_resource.ps_path}" \
    #{location_param} -filter "#{escaped_filter}" \
    -name "#{new_resource.property}" -ErrorAction Stop) -ne #{property_value}
    EOH
  end
end

action :add do
  location_param = "-location \"#{new_resource.location}\"" if
    property_is_set?(:location)

  # powershell doesn't like { or } in xpath values (e.g. server variables)
  escaped_value = new_resource.value.gsub('{', '{{').gsub('}', '}}')
  escaped_filter = new_resource.filter.gsub('{', '{{').gsub('}', '}}')

  powershell_script "Set #{new_resource.ps_path}#{new_resource.location}\
/#{escaped_filter}/#{new_resource.property}" do
    code <<-EOH
    Add-WebConfigurationProperty -pspath "#{new_resource.ps_path}" \
    #{location_param} -filter "#{escaped_filter}" \
    -name "." -value @{ #{new_resource.property} = '#{new_resource.value}'; } \
    -ErrorAction Stop
    EOH
    only_if <<-EOH
    (Get-WebConfiguration -pspath "#{new_resource.ps_path}" #{location_param} \
    -filter "#{escaped_filter}/*[@#{new_resource.property}='#{escaped_value}']" \
    -ErrorAction Stop) -eq $null
    EOH
  end
end

action :remove do
  location_param = "-location \"#{new_resource.location}\"" if
    property_is_set?(:location)

  # powershell doesn't like { or } in xpath values (e.g. server variables)
  escaped_value = new_resource.value.gsub('{', '{{').gsub('}', '}}')
  escaped_filter = new_resource.filter.gsub('{', '{{').gsub('}', '}}')

  powershell_script "Set #{new_resource.ps_path}#{new_resource.location}\
/#{escaped_filter}/#{new_resource.property}" do
    code <<-EOH
    Remove-WebConfigurationProperty -pspath "#{new_resource.ps_path}" \
    #{location_param} -filter "#{escaped_filter}" \
    -name "." -AtElement @{ #{new_resource.property} = \
    '#{new_resource.value}'; } -ErrorAction Stop
    EOH
    only_if <<-EOH
    (Get-WebConfiguration -pspath "#{new_resource.ps_path}" #{location_param} \
    -filter "#{escaped_filter}/*[@#{new_resource.property}='#{escaped_value}']" \
    -ErrorAction Stop) -ne $null
    EOH
  end
end

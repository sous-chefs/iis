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

include IISCookbook::Helper

property :property, String, name_property: true
property :ps_path, String, required: true
property :location, String
property :filter, String, required: true
property :value, [String, Integer, Hash], required: true

action :set do
  raise 'Set action does not support a Hash type for the value property' if new_resource.value.is_a?(Hash)

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

  escaped_filter = new_resource.filter.gsub('{', '{{').gsub('}', '}}')
  add_cmd = "Add-WebConfigurationProperty -ErrorAction Stop -PSPath #{new_resource.ps_path} #{location_param}"\
    "-Filter \"#{escaped_filter}\" -Name \".\""

  # powershell doesn't like { or } in xpath values (e.g. server variables)
  if new_resource.value.is_a?(Hash)
    add_cmd << " -Value #{to_powershell_hash(new_resource.value)}"
    guard_xpath = ''

    new_resource.value.each_with_index do |(k, v), idx|
      escaped_value = v.gsub('{', '{{').gsub('}', '}}')
      guard_xpath << "@#{k}=\'#{escaped_value}\'"
      guard_xpath << ' and ' unless idx == new_resource.value.size - 1
    end

    guard_xpath = "*[#{guard_xpath}]"
  else
    escaped_value = new_resource.value.gsub('{', '{{').gsub('}', '}}')
    add_cmd = "#{add_cmd} -Value @{ #{new_resource.property} = '#{new_resource.value}'; }"
    guard_xpath = "*[@#{new_resource.property}='#{escaped_value}']"
  end

  guard_cmd = <<-EOH
  (Get-WebConfiguration -PSPath "#{new_resource.ps_path}" #{location_param} \
  -Filter \"#{escaped_filter}/#{guard_xpath}\" -ErrorAction Stop) -eq $null
  EOH

  powershell_script "Set #{new_resource.ps_path}#{new_resource.location}\
/#{escaped_filter}/#{new_resource.property}" do
    code add_cmd
    only_if guard_cmd
  end
end

action :remove do
  raise 'Remove action does not support a Hash type for the value property' if new_resource.value.is_a?(Hash)

  location_param = "-location \"#{new_resource.location}\"" if
    property_is_set?(:location)

  # powershell doesn't like { or } in xpath values (e.g. server variables)
  escaped_value = new_resource.value.gsub('{', '{{').gsub('}', '}}')
  escaped_filter = filter.gsub('{', '{{').gsub('}', '}}')

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

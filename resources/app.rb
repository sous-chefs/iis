#
# Cookbook:: iis
# Resource:: app
#
# Copyright:: 2011-2017, Chef Software, Inc.
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

require 'rexml/document'

include REXML
include Opscode::IIS::Helper

property  :site_name,          String,        name_property: true
property  :path,               String,        default: '/'
property  :application_pool,   String
property  :physical_path,      String
property  :enabled_protocols,  String

default_action :add

load_current_value do |desired|
  site_name desired.site_name
  cmd = shell_out("#{appcmd(node)} list app")
  Chef::Log.debug("#{appcmd(node)} list app command output: #{cmd.stdout}")
  if cmd.stderr.empty?
    Chef::Log.debug('Running regex')
    regex = /^APP\s\"#{desired.site_name}#{desired.path}\"/
    result = cmd.stdout.match(regex)
    Chef::Log.debug("#{desired} current_resource match output: #{result}")
    if !result.nil?
      cmd_current_values = "#{appcmd(node)} list app \"#{desired.site_name}#{desired.path}\" /config:* /xml"
      Chef::Log.debug(cmd_current_values)
      cmd_current_values = shell_out(cmd_current_values)
      if cmd_current_values.stderr.empty?
        xml = cmd_current_values.stdout
        doc = Document.new(xml)
        path value doc.root, 'APP/application/@path'
        application_pool value doc.root, 'APP/application/@applicationPool'
        enabled_protocols value doc.root, 'APP/application/@enabledProtocols'
        physical_path value doc.root, 'APP/application/virtualDirectory/@physicalPath'
      end
    else
      path ''
    end
  else
    log "Failed to run iis_app action :load_current_resource, #{cmd_current_values.stderr}" do
      level :warn
    end
  end
end

action :add do
  if current_resource.path.empty?
    converge_by "Creating the Application - \"#{new_resource}\"" do
      cmd = "#{appcmd(node)} add app /site.name:\"#{new_resource.site_name}\""
      cmd << " /path:\"#{new_resource.path}\""
      cmd << " /applicationPool:\"#{new_resource.application_pool}\"" if new_resource.application_pool
      cmd << " /physicalPath:\"#{windows_cleanpath(new_resource.physical_path)}\"" if new_resource.physical_path
      cmd << " /enabledProtocols:\"#{new_resource.enabled_protocols}\"" if new_resource.enabled_protocols
      cmd << ' /commit:\"MACHINE/WEBROOT/APPHOST\"'
      Chef::Log.debug(cmd)
      shell_out!(cmd)
    end
  else
    Chef::Log.debug("#{new_resource.inspect} app already exists - nothing to do")
  end
end

action :config do
  # only get the beginning of the command if there is something that changes
  cmd = cmd_set_app
  converge_if_changed :path do
    # adds path to the cmd
    cmd << " /path:\"#{new_resource.path}\"" if new_resource.path
  end
  converge_if_changed :application_pool do
    # adds applicationPool to the cmd
    cmd << " /applicationPool:\"#{new_resource.application_pool}\"" if new_resource.application_pool
  end
  converge_if_changed :enabled_protocols do
    # adds enabledProtocols to the cmd
    cmd << " /enabledProtocols:\"#{new_resource.enabled_protocols}\"" if new_resource.enabled_protocols
  end
  Chef::Log.debug(cmd)

  if cmd == cmd_set_app
    Chef::Log.debug("#{new_resource.inspect} application - nothing to do")
  else
    shell_out!(cmd)
  end

  converge_if_changed :physical_path do
    cmd = "#{appcmd(node)} set vdir /vdir.name:\"#{vdir_identifier}\""
    cmd << " /physicalPath:\"#{windows_cleanpath(new_resource.physical_path)}\""
    Chef::Log.debug(cmd)
    shell_out!(cmd)
  end
end

action :delete do
  if !current_resource.path.empty?
    converge_by "Deleting the Application - \"#{new_resource}\"" do
      shell_out!("#{appcmd(node)} delete app \"#{site_identifier}\"")
      Chef::Log.info("#{new_resource} deleted")
    end
  else
    Chef::Log.debug("#{new_resource.inspect} app does not exist - nothing to do")
  end
end

action_class.class_eval do
  def cmd_set_app
    "#{appcmd(node)} set app \"#{site_identifier}\""
  end

  def site_identifier
    "#{new_resource.site_name}#{new_resource.path}"
  end

  # Ensure VDIR identifier has a trailing slash
  def vdir_identifier
    site_identifier.end_with?('/') ? site_identifier : site_identifier + '/'
  end
end

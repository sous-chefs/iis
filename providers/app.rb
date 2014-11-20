#
# Author:: Kendrick Martin (kendrick.martin@webtrends.com)
# Contributor:: Adam Wayne (awayne@waynedigital.com)
# Cookbook Name:: iis
# Provider:: app
#
# Copyright:: 2011, Webtrends Inc.
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

require 'chef/mixin/shell_out'
require 'rexml/document'

include Chef::Mixin::ShellOut
include Windows::Helper
include REXML

action :add do
  unless @current_resource.exists
    cmd = "#{Opscode::IIS::Helper.appcmd} add app /site.name:\"#{@new_resource.app_name}\""
    cmd << " /path:\"#{@new_resource.path}\""
    cmd << " /applicationPool:\"#{@new_resource.application_pool}\"" if @new_resource.application_pool
    cmd << " /physicalPath:\"#{win_friendly_path(@new_resource.physical_path)}\"" if @new_resource.physical_path
    cmd << " /enabledProtocols:\"#{@new_resource.enabled_protocols}\"" if @new_resource.enabled_protocols
    Chef::Log.debug(cmd)
    shell_out!(cmd)
    @new_resource.updated_by_last_action(true)
    Chef::Log.info("App created")
    @new_resource.updated_by_last_action(true)
  else
    Chef::Log.debug("#{@new_resource} app already exists - nothing to do")
  end
end

action :config do
  was_updated = false
  cmd_current_values = "#{Opscode::IIS::Helper.appcmd} list app \"#{site_identifier}\" /config:* /xml"
  Chef::Log.debug(cmd_current_values)
  cmd_current_values = shell_out(cmd_current_values)
  if cmd_current_values.stderr.empty?
    xml = cmd_current_values.stdout
    doc = Document.new(xml)
    path = XPath.first(doc.root, "APP/application/@path").to_s == @new_resource.path.to_s || @new_resource.path.to_s == '' ? false : true
    application_pool = XPath.first(doc.root, "APP/application/@applicationPool").to_s == @new_resource.application_pool.to_s || @new_resource.application_pool.to_s == '' ? false : true
    enabled_protocols = XPath.first(doc.root, "APP/application/@enabledProtocols").to_s == @new_resource.enabled_protocols.to_s || @new_resource.enabled_protocols.to_s == '' ? false : true
    physical_path = XPath.first(doc.root, "APP/application/virtualDirectory/@physicalPath").to_s == @new_resource.physical_path.to_s || @new_resource.physical_path.to_s == '' ? false : true
  end

  cmd = "#{Opscode::IIS::Helper.appcmd} set app \"#{site_identifier}\"" if @new_resource.path && path or @new_resource.application_pool && application_pool or @new_resource.enabled_protocols && enabled_protocols
  cmd << " /path:\"#{@new_resource.path}\"" if @new_resource.path && path
  cmd << " /applicationPool:\"#{@new_resource.application_pool}\"" if @new_resource.application_pool && application_pool
  cmd << " /enabledProtocols:\"#{@new_resource.enabled_protocols}\"" if @new_resource.enabled_protocols && enabled_protocols
  Chef::Log.debug(cmd)
  shell_out!(cmd)
  @new_resource.updated_by_last_action(true)

  if @new_resource.path && path or @new_resource.application_pool && application_pool or @new_resource.enabled_protocols && enabled_protocols
    was_updated = true
  end

  if @new_resource.physical_path && physical_path
    was_updated = true
    cmd = "#{Opscode::IIS::Helper.appcmd} set vdir /vdir.name:\"#{vdir_identifier}\""
    cmd << " /physicalPath:\"#{win_friendly_path(@new_resource.physical_path)}\""
    Chef::Log.debug(cmd)
    shell_out!(cmd)
  end

  if was_updated
    @new_resource.updated_by_last_action(true)
    Chef::Log.info("#{@new_resource} configured application")
  else
    Chef::Log.debug("#{@new_resource} application - nothing to do")
  end
end

action :delete do
  if @current_resource.exists
    shell_out!("#{Opscode::IIS::Helper.appcmd} delete app \"#{site_identifier}\"")
    @new_resource.updated_by_last_action(true)
    Chef::Log.info("#{@new_resource} deleted")
  else
    Chef::Log.debug("#{@new_resource} app does not exist - nothing to do")
  end
end

def load_current_resource
  @current_resource = Chef::Resource::IisApp.new(@new_resource.name)
  @current_resource.app_name(@new_resource.app_name)
  @current_resource.path(@new_resource.path)
  @current_resource.application_pool(@new_resource.application_pool)
  cmd = shell_out("#{Opscode::IIS::Helper.appcmd} list app")
  # APPPOOL "MyAppName" (applicationPool:MyAppPool)
  Chef::Log.debug("#{@new_resource} list app command output: #{cmd.stdout}")
  #result = cmd.stdout.match(/^APP\s\"#{@new_resource.app_name}#{@new_resource.path}\"/) if cmd.stderr.empty?
  result = cmd.stdout.match(/^APP\s\"#{@new_resource.app_name}#{@new_resource.path}\"\s\(applicationPool\:#{@new_resource.application_pool}\)/) if cmd.stderr.empty?
  Chef::Log.debug("Running regex")
  Chef::Log.debug("#{@new_resource} current_resource match output:#{result}")
  if result
    @current_resource.exists = true
  else
    @current_resource.exists = false
  end
end

private
def site_identifier
  "#{@new_resource.app_name}#{@new_resource.path}"
end

#Ensure VDIR identifier has a trailing slash
def vdir_identifier
  site_identifier.end_with?("/") ? site_identifier : site_identifier + "/"
end

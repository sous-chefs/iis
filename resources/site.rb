#
# Cookbook:: iis
# Resource:: site
#
# Copyright:: 2011-2016, Chef Software, Inc.
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
include REXML
include Opscode::IIS::Helper
include Opscode::IIS::Processors

property    :site_name,            String,              name_attribute: true
property    :site_id,              Integer
property    :port,                 Integer,             default: 80
property    :path,                 String
property    :protocol,             Symbol,              default: :http, equal_to: [:http, :https]
property    :host_header,          [String, nil],       default: nil
property    :bindings,             [String, nil],       default: nil
property    :application_pool,     [String, nil],       default: nil
property    :options,              String,              default: ''
property    :log_directory,        String,              default: node['iis']['log_dir']
property    :log_period,           Symbol,              default: :Daily, equal_to: [:Daily, :Hourly, :MaxSize, :Monthly, :Weekly]
property    :log_truncsize,        Integer,             default: 1_048_576
property    :exists,               [true, false],       desired_state: true
property    :running,              [true, false],       desired_state: true

load_current_value do |desired|
  site_name desired.site_name
  cmd = shell_out("#{appcmd(node)} list site")
  Chef::Log.debug(appcmd(node))
  # 'SITE "Default Web Site" (id:1,bindings:http/*:80:,state:Started)'
  Chef::Log.debug("#{desired} list site command output: #{cmd.stdout}")
  if cmd.stderr.empty?
    result = cmd.stdout.gsub(/\r\n?/, "\n") # ensure we have no carriage returns
    result = result.match(/^SITE\s\"(#{desired.site_name})\"\s\(id:(.*),bindings:(.*),state:(.*)\)$/i)
    Chef::Log.debug("#{desired} current_resource match output: #{result}")
    if result
      site_id result[2].to_i
      exists true
      bindings result[3]
      running result[4] =~ /Started/ ? true : false
    else
      exists false
      running false
    end
  else
    log "Failed to run iis_site action :config, #{cmd.stderr}" do
      level :warn
    end
  end
end

action :add do
  if !current_resource.exists
    cmd = "#{appcmd(node)} add site /name:\"#{new_resource.site_name}\""
    cmd << " /id:#{new_resource.site_id}" if new_resource.site_id
    cmd << " /physicalPath:\"#{windows_cleanpath(new_resource.path)}\"" if new_resource.path
    if new_resource.bindings
      cmd << " /bindings:\"#{new_resource.bindings}\""
    else
      cmd << " /bindings:#{new_resource.protocol}/*"
      cmd << ":#{new_resource.port}:" if new_resource.port
      cmd << new_resource.host_header if new_resource.host_header
    end

    # support for additional options -logDir, -limits, -ftpServer, etc...
    cmd << " #{new_resource.options}" if new_resource.options
    shell_out!(cmd, returns: [0, 42])

    configure

    if new_resource.application_pool
      shell_out!("#{appcmd(node)} set site /site.name:\"#{new_resource.site_name}\" /[path='/'].applicationPool:\"#{new_resource.application_pool}\"", returns: [0, 42])
    end
    new_resource.updated_by_last_action(true)
    Chef::Log.info("#{new_resource} added new site '#{new_resource.site_name}'")
  else
    Chef::Log.debug("#{new_resource} site already exists - nothing to do")
  end
end

action :config do
  new_resource.updated_by_last_action(true) if configure
end

action :delete do
  if current_resource.exists
    Chef::Log.info("#{appcmd(node)} stop site /site.name:\"#{new_resource.site_name}\"")
    shell_out!("#{appcmd(node)} delete site /site.name:\"#{new_resource.site_name}\"", returns: [0, 42])
    new_resource.updated_by_last_action(true)
    Chef::Log.info("#{new_resource} deleted")
  else
    Chef::Log.debug("#{new_resource} site does not exist - nothing to do")
  end
end

action :start do
  if !current_resource.running
    shell_out!("#{appcmd(node)} start site /site.name:\"#{new_resource.site_name}\"", returns: [0, 42])
    new_resource.updated_by_last_action(true)
    Chef::Log.info("#{new_resource} started")
  else
    Chef::Log.debug("#{new_resource} already running - nothing to do")
  end
end

action :stop do
  if current_resource.running
    Chef::Log.info("#{appcmd(node)} stop site /site.name:\"#{new_resource.site_name}\"")
    shell_out!("#{appcmd(node)} stop site /site.name:\"#{new_resource.site_name}\"", returns: [0, 42])
    new_resource.updated_by_last_action(true)
    Chef::Log.info("#{new_resource} stopped")
  else
    Chef::Log.debug("#{new_resource} already stopped - nothing to do")
  end
end

action :restart do
  shell_out!("#{appcmd(node)} stop site /site.name:\"#{new_resource.site_name}\"", returns: [0, 42])
  sleep 2
  shell_out!("#{appcmd(node)} start site /site.name:\"#{new_resource.site_name}\"", returns: [0, 42])
  new_resource.updated_by_last_action(true)
  Chef::Log.info("#{new_resource} restarted")
end

action_class do
  def configure
    was_updated = false
    cmd_current_values = "#{appcmd(node)} list site \"#{new_resource.site_name}\" /config:* /xml"
    Chef::Log.debug(cmd_current_values)
    cmd_current_values = shell_out(cmd_current_values)
    if cmd_current_values.stderr.empty?
      xml = cmd_current_values.stdout
      doc = Document.new(xml)
      is_new_bindings = new_value?(doc.root, 'SITE/@bindings', new_resource.bindings.to_s)
      is_new_physical_path = new_or_empty_value?(doc.root, 'SITE/site/application/virtualDirectory/@physicalPath', new_resource.path.to_s)
      is_new_port_host_provided = !"#{XPath.first(doc.root, 'SITE/@bindings')},".include?("#{new_resource.protocol}/*:#{new_resource.port}:#{new_resource.host_header},")
      is_new_site_id = new_value?(doc.root, 'SITE/site/@id', new_resource.site_id.to_s)
      is_new_log_directory = new_or_empty_value?(doc.root, 'SITE/site/logFile/@directory', new_resource.log_directory.to_s)
      is_new_log_period = new_or_empty_value?(doc.root, 'SITE/site/logFile/@period', new_resource.log_period.to_s)
      is_new_log_trunc = new_or_empty_value?(doc.root, 'SITE/site/logFile/@truncateSize', new_resource.log_truncsize.to_s)
      is_new_application_pool = new_value?(doc.root, 'SITE/site/application/@applicationPool', new_resource.application_pool)
  
      if new_resource.bindings && is_new_bindings
        was_updated = true
        cmd = "#{appcmd(node)} set site /site.name:\"#{new_resource.site_name}\""
        cmd << " /bindings:\"#{new_resource.bindings}\""
        shell_out!(cmd)
        new_resource.updated_by_last_action(true)
      elsif ((new_resource.port || new_resource.host_header || new_resource.protocol) && is_new_port_host_provided) && !new_resource.bindings
        was_updated = true
        cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
        cmd << " /bindings:#{new_resource.protocol}/*:#{new_resource.port}:#{new_resource.host_header}"
        Chef::Log.debug(cmd)
        shell_out!(cmd)
        new_resource.updated_by_last_action(true)
      end
  
      if new_resource.application_pool && is_new_application_pool
        was_updated = true
        cmd = "#{appcmd(node)} set app \"#{new_resource.site_name}/\" /applicationPool:\"#{new_resource.application_pool}\""
        Chef::Log.debug(cmd)
        shell_out!(cmd, returns: [0, 42])
      end
  
      if new_resource.path && is_new_physical_path
        was_updated = true
        cmd = "#{appcmd(node)} set vdir \"#{new_resource.site_name}/\""
        cmd << " /physicalPath:\"#{windows_cleanpath(new_resource.path)}\""
        Chef::Log.debug(cmd)
        shell_out!(cmd)
      end
  
      if new_resource.site_id && is_new_site_id
        was_updated = true
        cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
        cmd << " /id:#{new_resource.site_id}"
        Chef::Log.debug(cmd)
        shell_out!(cmd)
        new_resource.updated_by_last_action(true)
      end
  
      if new_resource.log_directory && is_new_log_directory
        was_updated = true
        cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
        cmd << " /logFile.directory:#{windows_cleanpath(new_resource.log_directory)}"
        Chef::Log.debug(cmd)
        shell_out!(cmd)
        new_resource.updated_by_last_action(true)
      end
  
      if new_resource.log_period && is_new_log_period
        was_updated = true
        cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
        cmd << " /logFile.period:#{new_resource.log_period}"
        Chef::Log.debug(cmd)
        shell_out!(cmd)
        new_resource.updated_by_last_action(true)
      end
  
      if new_resource.log_truncsize && is_new_log_trunc
        was_updated = true
        cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
        cmd << " /logFile.truncateSize:#{new_resource.log_truncsize}"
        Chef::Log.debug(cmd)
        shell_out!(cmd)
        new_resource.updated_by_last_action(true)
      end
  
      if was_updated
        Chef::Log.info("#{new_resource} configured site '#{new_resource.site_name}'")
      else
        Chef::Log.debug("#{new_resource} site - nothing to do")
      end
    else
      log "Failed to run iis_site action :config, #{cmd_current_values.stderr}" do
        level :warn
      end
    end
  
    was_updated
  end
end

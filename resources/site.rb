#
# Cookbook:: iis
# Resource:: site
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

require 'rexml/document'

include REXML
include Opscode::IIS::Helper
include Opscode::IIS::Processors

property    :site_name, String, name_property: true
property    :site_id, Integer
property    :port, Integer, default: 80, coerce: proc { |v| v.to_i }
property    :path, String
property    :protocol, [Symbol, String], equal_to: [:http, :https, :ftp], default: :http, coerce: proc { |v| v.to_sym }
property    :host_header, String
property    :bindings, String
property    :application_pool, String
property    :options, String, default: ''
property    :log_directory, String, default: node['iis']['log_dir']
property    :log_period, [Symbol, String], equal_to: [:Daily, :Hourly, :MaxSize, :Monthly, :Weekly], default: :Daily, coerce: proc { |v| v.to_sym }
property    :log_truncsize, Integer, default: 1_048_576
property    :running, [true, false], desired_state: true

default_action :add

load_current_value do |desired|
  site_name desired.site_name
  # Sanitize windows file system path
  desired.path = windows_cleanpath(desired.path) if desired.path
  desired.log_directory = windows_cleanpath(desired.log_directory) if desired.log_directory
  cmd = shell_out "#{appcmd(node)} list site \"#{site_name}\""
  Chef::Log.debug(appcmd(node))
  # 'SITE "Default Web Site" (id:1,bindings:http/*:80:,state:Started)'
  Chef::Log.debug("#{desired} list site command output: #{cmd.stdout}")
  if cmd.stderr.empty?
    result = cmd.stdout.gsub(/\r\n?/, "\n") # ensure we have no carriage returns
    result = result.match(/^SITE\s\"(?<site>#{desired.site_name})\"\s\(id:(?<site_id>.*),bindings:(?<bindings>.*),state:(?<state>.*)\)$/i)
    Chef::Log.debug("#{desired} current_resource match output: #{result}")
    if result
      site_id result[:site_id].to_i
      bindings result[:bindings]
      running result[:state] =~ /Started/ ? true : false
    else
      running false
    end

    if site_id
      values = "#{bindings},".match(%r{(?<protocol>[^\/]+)\/\*:(?<port>[^:]+):(?<host_header>[^,]*),})
      # get current values
      cmd = "#{appcmd(node)} list site \"#{site_name}\" /config:* /xml"
      Chef::Log.debug(cmd)
      cmd = shell_out cmd
      if cmd.stderr.empty?
        xml = cmd.stdout
        doc = Document.new(xml)
        path windows_cleanpath(value(doc.root, 'SITE/site/application/virtualDirectory/@physicalPath'))
        log_directory windows_cleanpath(value(doc.root, 'SITE/site/logFile/@directory'))
        log_period value(doc.root, 'SITE/site/logFile/@period').to_sym
        log_truncsize value(doc.root, 'SITE/site/logFile/@truncateSize').to_i
        application_pool value doc.root, 'SITE/site/application/@applicationPool'
      end

      if values
        protocol values[:protocol].to_sym
        port values[:port].to_i
        host_header values[:host_header]
      end
    else
      running false
    end

    if values
      protocol values[:protocol]
      port values[:port].to_i
      host_header values[:host_header]
    end
  else
    Chef::Log.warn "Failed to run iis_site action :config, #{cmd.stderr}"
  end
end

action :add do
  if exists
    Chef::Log.debug("#{new_resource} site already exists - nothing to do")
  else
    converge_by "Created the Site - \"#{new_resource}\"" do
      cmd = "#{appcmd(node)} add site /name:\"#{new_resource.site_name}\""
      cmd << " /id:#{new_resource.site_id}" if new_resource.site_id
      cmd << " /physicalPath:\"#{new_resource.path}\"" if new_resource.path
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
      Chef::Log.info("#{new_resource} added new site '#{new_resource.site_name}'")
    end
  end
end

action :config do
  configure if exists
end

action :delete do
  if exists
    converge_by "Deleted the Site - \"#{new_resource}\"" do
      Chef::Log.info("#{appcmd(node)} stop site /site.name:\"#{new_resource.site_name}\"")
      shell_out!("#{appcmd(node)} delete site /site.name:\"#{new_resource.site_name}\"", returns: [0, 42])
    end
  else
    Chef::Log.debug("#{new_resource} site does not exist - nothing to do")
  end
end

action :start do
  if exists && !current_resource.running
    converge_by "Started the Site - \"#{new_resource}\"" do
      shell_out!("#{appcmd(node)} start site /site.name:\"#{new_resource.site_name}\"", returns: [0, 42])
    end
  else
    Chef::Log.debug("#{new_resource} already running - nothing to do")
  end
end

action :stop do
  if exists && current_resource.running
    converge_by "Stopped the Site - \"#{new_resource}\"" do
      Chef::Log.info("#{appcmd(node)} stop site /site.name:\"#{new_resource.site_name}\"")
      shell_out!("#{appcmd(node)} stop site /site.name:\"#{new_resource.site_name}\"", returns: [0, 42])
    end
  else
    Chef::Log.debug("#{new_resource} already stopped - nothing to do")
  end
end

action :restart do
  converge_by "Restarted the Site - \"#{new_resource}\"" do
    shell_out!("#{appcmd(node)} stop site /site.name:\"#{new_resource.site_name}\"", returns: [0, 42]) if running
    sleep 2
    shell_out!("#{appcmd(node)} start site /site.name:\"#{new_resource.site_name}\"", returns: [0, 42])
  end
end

action_class.class_eval do
  def exists
    current_resource.site_id ? true : false
  end

  def configure
    if new_resource.bindings
      converge_if_changed :bindings do
        cmd = "#{appcmd(node)} set site /site.name:\"#{new_resource.site_name}\""
        cmd << " /bindings:\"#{new_resource.bindings}\""
        Chef::Log.debug(cmd)
        shell_out!(cmd)
      end
    elsif new_resource.port || new_resource.host_header || new_resource.protocol
      converge_if_changed :bindings, :host_header, :protocol do
        cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
        cmd << " /bindings:#{new_resource.protocol}/*:#{new_resource.port}:#{new_resource.host_header}"
        Chef::Log.debug(cmd)
        shell_out!(cmd)
      end
    end

    converge_if_changed :application_pool do
      cmd = "#{appcmd(node)} set app \"#{new_resource.site_name}/\" /applicationPool:\"#{new_resource.application_pool}\""
      Chef::Log.debug(cmd)
      shell_out!(cmd, returns: [0, 42])
    end

    converge_if_changed :path do
      cmd = "#{appcmd(node)} set vdir \"#{new_resource.site_name}/\""
      cmd << " /physicalPath:\"#{new_resource.path}\""
      Chef::Log.debug(cmd)
      shell_out!(cmd)
    end

    converge_if_changed :site_id do
      cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
      cmd << " /id:#{new_resource.site_id}"
      Chef::Log.debug(cmd)
      shell_out!(cmd)
    end

    converge_if_changed :log_directory do
      cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
      cmd << " /logFile.directory:#{new_resource.log_directory}"
      Chef::Log.debug(cmd)
      shell_out!(cmd)
    end

    converge_if_changed :log_period do
      cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
      cmd << " /logFile.period:#{new_resource.log_period}"
      Chef::Log.debug(cmd)
      shell_out!(cmd)
    end

    converge_if_changed :log_truncsize do
      cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
      cmd << " /logFile.truncateSize:#{new_resource.log_truncsize}"
      Chef::Log.debug(cmd)
      shell_out!(cmd)
    end
  end
end

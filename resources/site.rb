#
# Cookbook:: iis
# Resource:: site
#
# Copyright:: 2017-2018, Chef Software, Inc.
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
include IISCookbook::Helper
include IISCookbook::Processors

property    :site_name, String, name_property: true
property    :site_id, Integer
property    :port, Integer, default: 80, coerce: proc { |v| v.to_i }
property    :path, String
property    :protocol, [Symbol, String], equal_to: [:http, :https, :ftp], default: :http, coerce: proc { |v| v.to_sym }
property    :host_header, String
property    :bindings, String
property    :application_pool, String
property    :options, String, default: ''
property    :log_directory, String
property    :log_period, [Symbol, String], equal_to: [:Daily, :Hourly, :MaxSize, :Monthly, :Weekly], default: :Daily, coerce: proc { |v| v.to_sym }
property    :log_truncsize, Integer, default: 1_048_576
property    :running, [true, false]

load_current_value do |desired|
  site_name desired.site_name
  # Sanitize windows file system path
  desired.path = windows_cleanpath(desired.path) if desired.path
  desired.log_directory = windows_cleanpath(desired.log_directory) if desired.log_directory
  desired.port = desired.port.to_i if desired.port

  # Retrieve everything we need about the site
  cmd = "Get-Website -name '#{site_name}' | Select-Object -Property name,`
                                                                    id,`
                                                                    physicalPath,`
                                                                    state,`
                                                                    @{Name='bindings'; Expression = {$_.Bindings.Collection | ForEach-Object{$_.ToString()}}},`
                                                                    @{Name='applicationPool'; Expression = {$_.applicationPool}},`
                                                                    @{Name='logDirectory'; Expression = {$_.LogFile.Directory}},`
                                                                    @{Name='logPeriod'; Expression = {$_.LogFile.Period}},`
                                                                    @{Name='logTruncateSize'; Expression = {$_.LogFile.truncateSize}} | ConvertTo-Json -Compress"

  Chef::Log.debug("Retrieving site details via: #{cmd}")
  ps_results = powershell_out(cmd)

  if ps_results.stdout.empty?
    current_value_does_not_exist!
  end

  if ps_results.error?
    Chef::Log.debug("Error fetching config state: #{results.stderr}")
    current_value_does_not_exist!
  end

  results = Chef::JSONCompat.from_json(ps_results.stdout)
  Chef::Log.debug("Site details command output: #{results}")

  site_id results['id'].to_i
  bindings results['bindings']
  running results['state'] =~ /Started/ ? true : false

  # get current values
  path windows_cleanpath(results['physicalPath'])
  log_directory windows_cleanpath(results['logDirectory'])
  log_period results['logPeriod'].to_sym
  log_truncsize results['logTruncateSize'].to_i
  application_pool results['applicationPool']

  binding_values = "#{bindings},".match(%r{(?<protocol>[^\/]+)\/\*:(?<port>[^:]+):(?<host_header>[^,]*),?})

  if binding_values
    protocol binding_values[:protocol].to_sym
    port binding_values[:port].to_i
    host_header binding_values[:host_header]
  end
end

action :add do
  if @current_resource
    Chef::Log.debug("#{new_resource} site already exists - nothing to do")
  else
    converge_by "Created the Site - \"#{new_resource}\"" do
      cmd = "New-WebSite -Name '#{new_resource.site_name}'"
      cmd << " -ID '#{new_resource.site_id}'" if new_resource.site_id
      cmd << " -PhysicalPath '#{new_resource.path}'" if new_resource.path

      # ! Do we just move this into the configure step since we can't do it in one swoop?
      # if new_resource.bindings
      #   cmd << " /bindings:\"#{new_resource.bindings}\""
      # else
      #   cmd << " /bindings:#{new_resource.protocol}/*"
      #   cmd << ":#{new_resource.port}:" if new_resource.port
      #   cmd << new_resource.host_header if new_resource.host_header
      # end

      # ! We can't really support this with PowerShell
      # support for additional options -logDir, -limits, -ftpServer, etc...
      #cmd << " #{new_resource.options}" if new_resource.options
      #shell_out!(cmd, returns: [0, 42])
      powershell_out!(cmd)

      configure

      # ! This should really be moved too
      # if new_resource.application_pool
      #   shell_out!("#{appcmd(node)} set site /site.name:\"#{new_resource.site_name}\" /[path='/'].applicationPool:\"#{new_resource.application_pool}\"", returns: [0, 42])
      # end

      Chef::Log.info("#{new_resource} added new site '#{new_resource.site_name}'")
    end
  end
end

action :config do
  configure if @current_resource
end

action :delete do
  if @current_resource
    converge_by "Deleted the Site - \"#{new_resource}\"" do
      Chef::Log.info("#{appcmd(node)} stop site /site.name:\"#{new_resource.site_name}\"")
      shell_out!("#{appcmd(node)} delete site /site.name:\"#{new_resource.site_name}\"", returns: [0, 42])
    end
  else
    Chef::Log.debug("#{new_resource} site does not exist - nothing to do")
  end
end

action :start do
  if @current_resource && !current_resource.running
    converge_by "Started the Site - \"#{new_resource}\"" do
      shell_out!("#{appcmd(node)} start site /site.name:\"#{new_resource.site_name}\"", returns: [0, 42])
    end
  else
    Chef::Log.debug("#{new_resource} already running - nothing to do")
  end
end

action :stop do
  if @current_resource && current_resource.running
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
    shell_out!("#{appcmd(node)} stop site /site.name:\"#{new_resource.site_name}\"", returns: [0, 42]) if current_resource.running
    sleep 2
    shell_out!("#{appcmd(node)} start site /site.name:\"#{new_resource.site_name}\"", returns: [0, 42])
  end
end

action_class do
  def configure
    if new_resource.bindings
      converge_if_changed :bindings do
        cmd = "#{appcmd(node)} set site /site.name:\"#{new_resource.site_name}\""
        cmd << " /bindings:\"#{new_resource.bindings}\""
        Chef::Log.debug(cmd)
        shell_out!(cmd)
      end
    elsif new_resource.port || new_resource.host_header || new_resource.protocol
      converge_if_changed :host_header, :protocol, :port do
        cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
        cmd << " /bindings:#{new_resource.protocol}/*:#{new_resource.port}:#{new_resource.host_header}"
        Chef::Log.debug(cmd)
        shell_out!(cmd)
      end
    end

    if new_resource.application_pool
      converge_if_changed :application_pool do
        cmd = "#{appcmd(node)} set app \"#{new_resource.site_name}/\" /applicationPool:\"#{new_resource.application_pool}\""
        Chef::Log.debug(cmd)
        shell_out!(cmd, returns: [0, 42])
      end
    end

    if new_resource.site_id
      converge_if_changed :path do
        cmd = "#{appcmd(node)} set vdir \"#{new_resource.site_name}/\""
        cmd << " /physicalPath:\"#{new_resource.path}\""
        Chef::Log.debug(cmd)
        shell_out!(cmd)
      end
    end

    if new_resource.site_id
      converge_if_changed :site_id do
        cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
        cmd << " /id:#{new_resource.site_id}"
        Chef::Log.debug(cmd)
        shell_out!(cmd)
      end
    end

    if new_resource.log_directory
      converge_if_changed :log_directory do
        cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
        cmd << " /logFile.directory:#{new_resource.log_directory}"
        Chef::Log.debug(cmd)
        shell_out!(cmd)
      end
    end

    if new_resource.log_period
      converge_if_changed :log_period do
        cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
        cmd << " /logFile.period:#{new_resource.log_period}"
        Chef::Log.debug(cmd)
        shell_out!(cmd)
      end
    end

    if new_resource.log_truncsize
      converge_if_changed :log_truncsize do
        cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
        cmd << " /logFile.truncateSize:#{new_resource.log_truncsize}"
        Chef::Log.debug(cmd)
        shell_out!(cmd)
      end
    end
  end
end

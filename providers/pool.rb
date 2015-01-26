#
# Author:: Kendrick Martin (kendrick.martin@webtrends.com)
# Contributor:: David Dvorak (david.dvorak@webtrends.com)
# Cookbook Name:: iis
# Provider:: pool
#
# Copyright:: 2011, Webtrends Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
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

action :add do
  unless @current_resource.exists
    cmd = "#{appcmd(node)} add apppool /name:\"#{@new_resource.pool_name}\""
    cmd << " /managedRuntimeVersion:" if @new_resource.runtime_version || @new_resource.no_managed_code
    cmd << "v#{@new_resource.runtime_version}" if @new_resource.runtime_version && !@new_resource.no_managed_code
    cmd << " /managedPipelineMode:#{@new_resource.pipeline_mode}" if @new_resource.pipeline_mode
    Chef::Log.debug(cmd)
    shell_out!(cmd)
    configure
    @new_resource.updated_by_last_action(true)
    Chef::Log.info("App pool created")
  else
    Chef::Log.debug("#{@new_resource} pool already exists - nothing to do")
  end
end

action :config do
  configure
end

action :delete do
  if @current_resource.exists
    shell_out!("#{appcmd(node)} delete apppool \"#{site_identifier}\"")
    @new_resource.updated_by_last_action(true)
    Chef::Log.info("#{@new_resource} deleted")
  else
    Chef::Log.debug("#{@new_resource} pool does not exist - nothing to do")
  end
end

action :start do
  unless @current_resource.running
    shell_out!("#{appcmd(node)} start apppool \"#{site_identifier}\"")
    @new_resource.updated_by_last_action(true)
    Chef::Log.info("#{@new_resource} started")
  else
    Chef::Log.debug("#{@new_resource} already running - nothing to do")
  end
end

action :stop do
  if @current_resource.running
    shell_out!("#{appcmd(node)} stop apppool \"#{site_identifier}\"")
    @new_resource.updated_by_last_action(true)
    Chef::Log.info("#{@new_resource} stopped")
  else
    Chef::Log.debug("#{@new_resource} already stopped - nothing to do")
  end
end

action :restart do
  shell_out!("#{appcmd(node)} stop APPPOOL \"#{site_identifier}\"")
  sleep 2
  shell_out!("#{appcmd(node)} start APPPOOL \"#{site_identifier}\"")
  @new_resource.updated_by_last_action(true)
  Chef::Log.info("#{@new_resource} restarted")
end

action :recycle do
  shell_out!("#{appcmd(node)} recycle APPPOOL \"#{site_identifier}\"")
  @new_resource.updated_by_last_action(true)
  Chef::Log.info("#{@new_resource} recycled")
end

def load_current_resource
  @current_resource = Chef::Resource::IisPool.new(@new_resource.name)
  @current_resource.pool_name(@new_resource.pool_name)
  cmd = shell_out("#{appcmd(node)} list apppool")
  # APPPOOL "DefaultAppPool" (MgdVersion:v2.0,MgdMode:Integrated,state:Started)
  Chef::Log.debug("#{@new_resource} list apppool command output: #{cmd.stdout}")
  if cmd.stderr.empty?
    result = cmd.stdout.gsub(/\r\n?/, "\n") # ensure we have no carriage returns
    result = result.match(/^APPPOOL\s\"(#{new_resource.pool_name})\"\s\(MgdVersion:(.*),MgdMode:(.*),state:(.*)\)$/)
    Chef::Log.debug("#{@new_resource} current_resource match output: #{result}")
    if result
      @current_resource.exists = true
      @current_resource.running = (result[4] =~ /Started/) ? true : false
    else
      @current_resource.exists = false
      @current_resource.running = false
    end
  else
    log "Failed to run iis_pool action :load_current_resource, #{cmd_current_values.stderr}" do
      level :warn
    end
  end
end

private
def site_identifier
  @new_resource.pool_name
end

def configure
  was_updated = false
  cmd_current_values = "#{appcmd(node)} list apppool \"#{@new_resource.pool_name}\" /config:* /xml"
  Chef::Log.debug(cmd_current_values)
  cmd_current_values = shell_out(cmd_current_values)
  if cmd_current_values.stderr.empty?
    xml = cmd_current_values.stdout
    doc = Document.new(xml)
    is_new_log_event_on_recycle = is_new_value?(doc.root, "APPPOOL/add/recycling/@logEventOnRecycle", "Time, Requests, Schedule, Memory, IsapiUnhealthy, OnDemand, ConfigChange, PrivateMemory")
    is_new_private_memory = is_new_or_empty_value?(doc.root, "APPPOOL/add/recycling/periodicRestart/@privateMemory", @new_resource.private_mem.to_s)
    is_new_max_processes = is_new_or_empty_value?(doc.root, "APPPOOL/add/processModel/@maxProcesses", @new_resource.max_proc.to_s)
    is_new_enable_32_bit_app_on_win_64 = is_new_or_empty_value?(doc.root, "APPPOOL/add/@enable32BitAppOnWin64", @new_resource.thirty_two_bit.to_s)
    is_new_recycle_after_time = is_new_or_empty_value?(doc.root, "APPPOOL/add/recycling/periodicRestart/@time", @new_resource.recycle_after_time.to_s)
    is_new_recycle_at_time = is_new_or_empty_value?(doc.root, "APPPOOL/add/recycling/periodicRestart/schedule/add/@value", @new_resource.recycle_at_time.to_s)
    is_new_managed_runtime_version = is_new_value?(doc.root, "APPPOOL/@RuntimeVersion", "v#{@new_resource.runtime_version}")
    is_new_idle_timeout = is_new_or_empty_value?(doc.root, "APPPOOL/add/recycling/periodicRestart/schedule/add/@value", @new_resource.recycle_at_time.to_s)
    is_new_identity_type = is_new_value?(doc.root, "APPPOOL/add/processModel/@identityType", @new_resource.pool_identity.to_s)
    is_new_user_name = is_new_or_empty_value?(doc.root, "APPPOOL/add/processModel/@userName", @new_resource.pool_username.to_s)
    is_new_password = is_new_or_empty_value?(doc.root, "APPPOOL/add/processModel/@password", @new_resource.pool_password.to_s)

    if is_new_log_event_on_recycle
      was_updated = true
      cmd = "#{appcmd(node)} set config /section:applicationPools "
      cmd << "\"/[name='#{@new_resource.pool_name}'].recycling.logEventOnRecycle:"
      cmd << "PrivateMemory,Memory,Schedule,Requests,Time,ConfigChange,OnDemand,IsapiUnhealthy\""
      Chef::Log.debug(cmd)
      shell_out!(cmd)
      @new_resource.updated_by_last_action(true)
    end
    if @new_resource.private_mem && is_new_private_memory
      was_updated = true
      cmd = "#{appcmd(node)} set config /section:applicationPools"
      cmd << " \"/[name='#{@new_resource.pool_name}'].recycling.periodicRestart.privateMemory:"
      cmd << "#{@new_resource.private_mem}\""
      Chef::Log.debug(cmd)
      shell_out!(cmd)
      @new_resource.updated_by_last_action(true)
    end
    if @new_resource.max_proc && is_new_max_processes
      was_updated = true
      cmd = "#{appcmd(node)} set apppool \"#{@new_resource.pool_name}\""
      cmd << " -processModel.maxProcesses:#{@new_resource.max_proc}"
      Chef::Log.debug(cmd)
      shell_out!(cmd)
      @new_resource.updated_by_last_action(true)
    end
    if @new_resource.thirty_two_bit && is_new_enable_32_bit_app_on_win_64
      was_updated = true
      cmd = "#{appcmd(node)} set apppool \"/apppool.name:#{@new_resource.pool_name}\""
      cmd << " /enable32BitAppOnWin64:#{@new_resource.thirty_two_bit}"
      Chef::Log.debug(cmd)
      shell_out!(cmd)
      @new_resource.updated_by_last_action(true)
    end
    if @new_resource.recycle_after_time && is_new_recycle_after_time
      was_updated = true
      cmd = "#{appcmd(node)} set apppool \"/apppool.name:#{@new_resource.pool_name}\""
      cmd << " /recycling.periodicRestart.time:#{@new_resource.recycle_after_time}"
      Chef::Log.debug(cmd)
      shell_out!(cmd)
      @new_resource.updated_by_last_action(true)
    end
    if @new_resource.recycle_at_time && is_new_recycle_at_time
      was_updated = true
      cmd = "#{appcmd(node)} set apppool \"/apppool.name:#{@new_resource.pool_name}\""
      cmd << " /-recycling.periodicRestart.schedule"
      Chef::Log.debug(cmd)
      shell_out!(cmd)
      @new_resource.updated_by_last_action(true)
      cmd = "#{appcmd(node)} set apppool \"/apppool.name:#{@new_resource.pool_name}\""
      cmd << " /+recycling.periodicRestart.schedule.[value='#{@new_resource.recycle_at_time}']"
      Chef::Log.debug(cmd)
      shell_out!(cmd)
      @new_resource.updated_by_last_action(true)
    end
    if @new_resource.runtime_version && is_new_managed_runtime_version
      was_updated = true
      cmd = "#{appcmd(node)} set apppool \"/apppool.name:#{@new_resource.pool_name}\""
      cmd << " /managedRuntimeVersion:v#{@new_resource.runtime_version}"
      Chef::Log.debug(cmd) if @new_resource.runtime_version
      shell_out!(cmd)
      @new_resource.updated_by_last_action(true)
    end
    if @new_resource.worker_idle_timeout && is_new_idle_timeout
      was_updated = true
      cmd = "#{appcmd(node)} set config /section:applicationPools"
      cmd << " \"/[name='#{@new_resource.pool_name}'].processModel.idleTimeout:#{@new_resource.worker_idle_timeout}\""
      Chef::Log.debug(cmd)
      shell_out!(cmd)
      @new_resource.updated_by_last_action(true)
    end
    if ((@new_resource.pool_username && @new_resource.pool_username != '') and
      (@new_resource.pool_password && @new_resource.pool_password != '') and
      !is_new_user_name and
      !is_new_password)
      was_updated = true
      cmd = "#{appcmd(node)} set config /section:applicationPools"
      cmd << " \"/[name='#{@new_resource.pool_name}'].processModel.identityType:SpecificUser\""
      cmd << " \"/[name='#{@new_resource.pool_name}'].processModel.userName:#{@new_resource.pool_username}\""
      cmd << " \"/[name='#{@new_resource.pool_name}'].processModel.password:#{@new_resource.pool_password}\""
      Chef::Log.debug(cmd)
      shell_out!(cmd)
      @new_resource.updated_by_last_action(true)
    elsif ((@new_resource.pool_username.nil? || @new_resource.pool_username == '') and
      (@new_resource.pool_password.nil? || @new_resource.pool_username == '') and
      (is_new_identity_type and @new_resource.pool_identity != "SpecificUser"))
      was_updated = true
      cmd = "#{appcmd(node)} set config /section:applicationPools"
      cmd << " \"/[name='#{@new_resource.pool_name}'].processModel.identityType:#{@new_resource.pool_identity}\""
      Chef::Log.debug(cmd)
      shell_out!(cmd)
      @new_resource.updated_by_last_action(true)
    end

    if was_updated
      @new_resource.updated_by_last_action(true)
      Chef::Log.info("#{@new_resource} configured application pool")
    else
      Chef::Log.debug("#{@new_resource} application pool - nothing to do")
    end
  else
    log "Failed to run iis_pool action :config, #{cmd_current_values.stderr}" do
      level :warn
    end
  end
end
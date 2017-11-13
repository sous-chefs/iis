#
# Cookbook:: iis
# Resource:: pool
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

# root
property :name, String, name_property: true
property :no_managed_code, [true, false], default: false
property :pipeline_mode, [Symbol, String], equal_to: [:Integrated, :Classic], coerce: proc { |v| v.to_sym }
property :runtime_version, String

# add items
property :start_mode, [Symbol, String], equal_to: [:AlwaysRunning, :OnDemand], default: :OnDemand, coerce: proc { |v| v.to_sym }
property :auto_start, [true, false], default: true
property :queue_length, Integer, default: 1000, coerce: proc { |v| v.to_i }
property :thirty_two_bit, [true, false], default: false

# processModel items
property :max_processes, Integer, coerce: proc { |v| v.to_i }
property :load_user_profile, [true, false], default: false
property :identity_type, [Symbol, String], equal_to: [:SpecificUser, :NetworkService, :LocalService, :LocalSystem, :ApplicationPoolIdentity], default: :ApplicationPoolIdentity, coerce: proc { |v| v.to_sym }
property :username, String
property :password, String
property :logon_type, [Symbol, String], equal_to: [:LogonBatch, :LogonService], default: :LogonBatch, coerce: proc { |v| v.to_sym }
property :manual_group_membership, [true, false], default: false
property :idle_timeout, String, default: '00:20:00'
property :idle_timeout_action, [Symbol, String], equal_to: [:Terminate, :Suspend], default: :Terminate, coerce: proc { |v| v.to_sym }
property :shutdown_time_limit, String, default: '00:01:30'
property :startup_time_limit, String, default: '00:01:30'
property :pinging_enabled, [true, false], default: true
property :ping_interval, String, default: '00:00:30'
property :ping_response_time, String, default: '00:01:30'

# recycling items
property :disallow_rotation_on_config_change, [true, false], default: false
property :disallow_overlapping_rotation, [true, false], default: false
property :recycle_schedule_clear, [true, false], default: false
property :log_event_on_recycle, String, default: node['iis']['recycle']['log_events']
property :recycle_after_time, String
property :periodic_restart_schedule, [Array, String], default: [], coerce: proc { |v| [*v].sort }
property :private_memory, Integer, coerce: proc { |v| v.to_i }
property :virtual_memory, Integer, coerce: proc { |v| v.to_i }

# failure items
property :load_balancer_capabilities, [Symbol, String], equal_to: [:HttpLevel, :TcpLevel], default: :HttpLevel, coerce: proc { |v| v.to_sym }
property :orphan_worker_process, [true, false], default: false
property :orphan_action_exe, String
property :orphan_action_params, String
property :rapid_fail_protection, [true, false], default: true
property :rapid_fail_protection_interval, String, default: '00:05:00'
property :rapid_fail_protection_max_crashes, Integer, default: 5, coerce: proc { |v| v.to_i }
property :auto_shutdown_exe, String
property :auto_shutdown_params, String

# cpu items
property :cpu_action, [Symbol, String], equal_to: [:NoAction, :KillW3wp, :Throttle, :ThrottleUnderLoad], default: :NoAction, coerce: proc { |v| v.to_sym }
property :cpu_limit, Integer, default: 0, coerce: proc { |v| v.to_i }
property :cpu_reset_interval, String, default: '00:05:00'
property :cpu_smp_affinitized, [true, false], default: false
property :smp_processor_affinity_mask, Float, default: 4_294_967_295.0, coerce: proc { |v| v.to_f }
property :smp_processor_affinity_mask_2, Float, default: 4_294_967_295.0, coerce: proc { |v| v.to_f }

# internally used for the state of the pool [Starting, Started, Stopping, Stopped, Unknown, Undefined value]
property :running, [true, false], desired_state: true

# Alias property until the next major release
alias_method :recycle_at_time, :periodic_restart_schedule

default_action :add

load_current_value do |desired|
  name desired.name
  cmd = shell_out("#{appcmd(node)} list apppool \"#{desired.name}\"")
  # APPPOOL "DefaultAppPool" (MgdVersion:v2.0,MgdMode:Integrated,state:Started)
  Chef::Log.debug("#{desired} list apppool command output: #{cmd.stdout}")
  unless cmd.stderr.empty?
    Chef::Log.warn "Failed to run iis_pool action :load_current_resource, #{cmd.stderr}"
    return
  end

  result = cmd.stdout.gsub(/\r\n?/, "\n") # ensure we have no carriage returns
  result = result.match(/^APPPOOL\s\"(#{desired.name})\"\s\(MgdVersion:(.*),MgdMode:(.*),state:(.*)\)$/i)
  Chef::Log.debug("#{desired} current_resource match output: #{result}")
  unless result
    running false
    return
  end

  running result[4] =~ /Started/ ? true : false
  cmd_current_values = "#{appcmd(node)} list apppool \"#{desired.name}\" /config:* /xml"
  Chef::Log.debug(cmd_current_values)
  cmd_current_values = shell_out(cmd_current_values)
  if cmd_current_values.stderr.empty?
    xml = cmd_current_values.stdout
    doc = Document.new(xml)

    # root items
    runtime_version value(doc.root, 'APPPOOL/@RuntimeVersion').gsub(/^v/, '')
    pipeline_mode value(doc.root, 'APPPOOL/@PipelineMode').to_sym

    # add items
    auto_start bool(value(doc.root, 'APPPOOL/add/@autoStart')) if iis_version >= 7.0
    start_mode value(doc.root, 'APPPOOL/add/@startMode').to_sym if iis_version > 7.0
    queue_length value(doc.root, 'APPPOOL/add/@queueLength').to_i
    thirty_two_bit bool(value(doc.root, 'APPPOOL/add/@enable32BitAppOnWin64'))

    # processModel items
    max_processes value(doc.root, 'APPPOOL/add/processModel/@maxProcesses').to_i
    load_user_profile bool(value(doc.root, 'APPPOOL/add/processModel/@loadUserProfile'))
    identity_type value(doc.root, 'APPPOOL/add/processModel/@identityType').to_sym if iis_version > 7.0
    username value doc.root, 'APPPOOL/add/processModel/@userName'
    unless username.nil? || desired.username.nil?
      Chef::Log.info('username: ' + username + ' -> ' + desired.username)
    end
    password value doc.root, 'APPPOOL/add/processModel/@password'
    logon_type value(doc.root, 'APPPOOL/add/processModel/@logonType').to_sym if iis_version > 7.0
    manual_group_membership bool(value(doc.root, 'APPPOOL/add/processModel/@manualGroupMembership'))
    idle_timeout value doc.root, 'APPPOOL/add/processModel/@idleTimeout'
    idle_timeout_action value(doc.root, 'APPPOOL/add/processModel/@idleTimeoutAction').to_sym if iis_version >= 8.5
    shutdown_time_limit value doc.root, 'APPPOOL/add/processModel/@shutdownTimeLimit'
    startup_time_limit value doc.root, 'APPPOOL/add/processModel/@startupTimeLimit'
    pinging_enabled bool(value(doc.root, 'APPPOOL/add/processModel/@pingingEnabled'))
    ping_interval value doc.root, 'APPPOOL/add/processModel/@pingInterval'
    ping_response_time value doc.root, 'APPPOOL/add/processModel/@pingResponseTime'

    # recycling items
    disallow_overlapping_rotation bool(value(doc.root, 'APPPOOL/add/recycling/@disallowOverlappingRotation'))
    disallow_rotation_on_config_change bool(value(doc.root, 'APPPOOL/add/recycling/@disallowRotationOnConfigChange'))
    recycle_after_time value doc.root, 'APPPOOL/add/recycling/periodicRestart/@time'
    periodic_restart_schedule get_value(doc.root, 'APPPOOL/add/recycling/periodicRestart/schedule/add/@value').map(&:value)
    private_memory value(doc.root, 'APPPOOL/add/recycling/periodicRestart/@privateMemory').to_i
    virtual_memory value(doc.root, 'APPPOOL/add/recycling/periodicRestart/@memory').to_i
    log_event_on_recycle value doc.root, 'APPPOOL/add/recycling/@logEventOnRecycle'

    # failure items
    load_balancer_capabilities value(doc.root, 'APPPOOL/add/failure/@loadBalancerCapabilities').to_sym
    orphan_worker_process bool(value(doc.root, 'APPPOOL/add/failure/@orphanWorkerProcess'))
    orphan_action_exe value doc.root, 'APPPOOL/add/failure/@orphanActionExe'
    orphan_action_params value doc.root, 'APPPOOL/add/failure/@orphanActionParams'
    rapid_fail_protection bool(value(doc.root, 'APPPOOL/add/failure/@rapidFailProtection'))
    rapid_fail_protection_interval value doc.root, 'APPPOOL/add/failure/@rapidFailProtectionInterval'
    rapid_fail_protection_max_crashes value(doc.root, 'APPPOOL/add/failure/@rapidFailProtectionMaxCrashes').to_i
    auto_shutdown_exe value doc.root, 'APPPOOL/add/failure/@autoShutdownExe'
    auto_shutdown_params value doc.root, 'APPPOOL/add/failure/@autoShutdownParams'

    # cpu items
    cpu_action value(doc.root, 'APPPOOL/add/cpu/@action').to_sym
    cpu_limit value(doc.root, 'APPPOOL/add/cpu/@limit').to_i
    cpu_smp_affinitized bool(value(doc.root, 'APPPOOL/add/cpu/@smpAffinitized'))
    cpu_reset_interval value doc.root, 'APPPOOL/add/cpu/@resetInterval'
    smp_processor_affinity_mask value(doc.root, 'APPPOOL/add/cpu/@smpProcessorAffinityMask').to_f
    smp_processor_affinity_mask_2 value(doc.root, 'APPPOOL/add/cpu/@smpProcessorAffinityMask2').to_f

    @node_array = XPath.match(doc.root, 'APPPOOL/add/recycling/periodicRestart/schedule/add')
  end
end

action :add do
  if exists
    Chef::Log.debug("#{new_resource} pool already exists - nothing to do")
  else
    converge_by "Created Application Pool \"#{new_resource}\"" do
      cmd = "#{appcmd(node)} add apppool /name:\"#{new_resource.name}\""
      if new_resource.no_managed_code
        cmd << ' /managedRuntimeVersion:'
      elsif new_resource.runtime_version
        cmd << " /managedRuntimeVersion:v#{new_resource.runtime_version}"
      end
      cmd << " /managedPipelineMode:#{new_resource.pipeline_mode.capitalize}" if new_resource.pipeline_mode
      cmd << ' /commit:\"MACHINE/WEBROOT/APPHOST\"'
      Chef::Log.debug(cmd)
      shell_out!(cmd)
      configure
    end
  end
end

action :config do
  configure if exists
end

action :delete do
  if exists
    converge_by "Deleted Application Pool \"#{new_resource}\"" do
      shell_out!("#{appcmd(node)} delete apppool \"#{new_resource.name}\"")
    end
  else
    Chef::Log.debug("#{new_resource} pool does not exist - nothing to do")
  end
end

action :start do
  if exists && !current_resource.running
    converge_by "Started Application Pool \"#{new_resource}\"" do
      shell_out!("#{appcmd(node)} start apppool \"#{new_resource.name}\"")
    end
  else
    Chef::Log.debug("#{new_resource} already running - nothing to do")
  end
end

action :stop do
  if exists && current_resource.running
    converge_by "Stopped Application Pool \"#{new_resource}\"" do
      shell_out!("#{appcmd(node)} stop apppool \"#{new_resource.name}\"")
    end
  else
    Chef::Log.debug("#{new_resource} already stopped - nothing to do")
  end
end

action :restart do
  if exists
    converge_by "Restarted Application Pool \"#{new_resource}\"" do
      shell_out!("#{appcmd(node)} stop APPPOOL \"#{new_resource.name}\"") if current_resource.running
      sleep 2
      shell_out!("#{appcmd(node)} start APPPOOL \"#{new_resource.name}\"")
    end
  end
end

action :recycle do
  if exists
    converge_by "Recycled Application Pool \"#{new_resource}\"" do
      shell_out!("#{appcmd(node)} recycle APPPOOL \"#{new_resource.name}\"") if current_resource.running
    end
  end
end

action_class.class_eval do
  def exists
    current_resource.runtime_version ? true : false
  end

  def configure
    # Application Pool Config
    cmd = "#{appcmd(node)} set config /section:applicationPools"

    # root items
    if iis_version >= 7.0
      converge_if_changed :auto_start do
        cmd << configure_application_pool("autoStart:#{new_resource.auto_start}")
      end
    end

    if iis_version >= 7.5
      converge_if_changed :start_mode do
        cmd << configure_application_pool("startMode:#{new_resource.start_mode}")
      end
    end

    if new_resource.no_managed_code
      converge_if_changed :runtime_version do
        cmd << configure_application_pool('managedRuntimeVersion:')
      end
    else
      converge_if_changed :runtime_version do
        cmd << configure_application_pool("managedRuntimeVersion:v#{new_resource.runtime_version}")
      end
    end

    converge_if_changed :pipeline_mode do
      cmd << configure_application_pool("managedPipelineMode:#{new_resource.pipeline_mode}")
    end
    converge_if_changed :thirty_two_bit do
      cmd << configure_application_pool("enable32BitAppOnWin64:#{new_resource.thirty_two_bit}")
    end
    converge_if_changed :queue_length do
      cmd << configure_application_pool("queueLength:#{new_resource.queue_length}")
    end

    # processModel items
    converge_if_changed :max_processes do
      cmd << configure_application_pool("processModel.maxProcesses:#{new_resource.max_processes}")
    end
    converge_if_changed :load_user_profile do
      cmd << configure_application_pool("processModel.loadUserProfile:#{new_resource.load_user_profile}")
    end
    converge_if_changed :logon_type do
      cmd << configure_application_pool("processModel.logonType:#{new_resource.logon_type}")
    end
    converge_if_changed :manual_group_membership do
      cmd << configure_application_pool("processModel.manualGroupMembership:#{new_resource.manual_group_membership}")
    end
    converge_if_changed :idle_timeout do
      cmd << configure_application_pool("processModel.idleTimeout:#{new_resource.idle_timeout}")
    end
    if iis_version >= 8.5
      converge_if_changed :idle_timeout_action do
        cmd << configure_application_pool("processModel.idleTimeoutAction:#{new_resource.idle_timeout_action}")
      end
    end
    converge_if_changed :shutdown_time_limit do
      cmd << configure_application_pool("processModel.shutdownTimeLimit:#{new_resource.shutdown_time_limit}")
    end
    converge_if_changed :startup_time_limit do
      cmd << configure_application_pool("processModel.startupTimeLimit:#{new_resource.startup_time_limit}")
    end
    converge_if_changed :pinging_enabled do
      cmd << configure_application_pool("processModel.pingingEnabled:#{new_resource.pinging_enabled}")
    end
    converge_if_changed :ping_interval do
      cmd << configure_application_pool("processModel.pingInterval:#{new_resource.ping_interval}")
    end
    converge_if_changed :ping_response_time do
      cmd << configure_application_pool("processModel.pingResponseTime:#{new_resource.ping_response_time}")
    end

    converge_if_changed :periodic_restart_schedule do
      # Remove the values that are no longer required
      ([*current_resource.periodic_restart_schedule] - [*new_resource.periodic_restart_schedule]).each do |periodic_restart|
        cmd << configure_application_pool("recycling.periodicRestart.schedule.[value='#{periodic_restart}']", '-')
      end

      # Add the new values
      ([*new_resource.periodic_restart_schedule] - [*current_resource.periodic_restart_schedule]).each do |periodic_restart|
        cmd << configure_application_pool("recycling.periodicRestart.schedule.[value='#{periodic_restart}']", '+')
      end
    end

    converge_if_changed :recycle_after_time do
      cmd << configure_application_pool("recycling.periodicRestart.time:#{new_resource.recycle_after_time}")
    end

    converge_if_changed :log_event_on_recycle do
      cmd << configure_application_pool("recycling.logEventOnRecycle:#{new_resource.log_event_on_recycle}")
    end
    converge_if_changed :private_memory do
      cmd << configure_application_pool("recycling.periodicRestart.privateMemory:#{new_resource.private_memory}")
    end
    converge_if_changed :virtual_memory do
      cmd << configure_application_pool("recycling.periodicRestart.memory:#{new_resource.virtual_memory}")
    end
    converge_if_changed :disallow_rotation_on_config_change do
      cmd << configure_application_pool("recycling.disallowRotationOnConfigChange:#{new_resource.disallow_rotation_on_config_change}")
    end
    converge_if_changed :disallow_overlapping_rotation do
      cmd << configure_application_pool("recycling.disallowOverlappingRotation:#{new_resource.disallow_overlapping_rotation}")
    end

    # failure items
    converge_if_changed :load_balancer_capabilities do
      cmd << configure_application_pool("failure.loadBalancerCapabilities:#{new_resource.load_balancer_capabilities}")
    end
    converge_if_changed :orphan_worker_process do
      cmd << configure_application_pool("failure.orphanWorkerProcess:#{new_resource.orphan_worker_process}")
    end
    converge_if_changed :orphan_action_exe do
      cmd << configure_application_pool("failure.orphanActionExe:#{new_resource.orphan_action_exe}")
    end
    converge_if_changed :orphan_action_params do
      cmd << configure_application_pool("failure.orphanActionParams:#{new_resource.orphan_action_params}")
    end
    converge_if_changed :rapid_fail_protection do
      cmd << configure_application_pool("failure.rapidFailProtection:#{new_resource.rapid_fail_protection}")
    end
    converge_if_changed :rapid_fail_protection_interval do
      cmd << configure_application_pool("failure.rapidFailProtectionInterval:#{new_resource.rapid_fail_protection_interval}")
    end
    converge_if_changed :rapid_fail_protection_max_crashes do
      cmd << configure_application_pool("failure.rapidFailProtectionMaxCrashes:#{new_resource.rapid_fail_protection_max_crashes}")
    end
    converge_if_changed :auto_shutdown_exe do
      cmd << configure_application_pool("failure.autoShutdownExe:#{new_resource.auto_shutdown_exe}")
    end
    converge_if_changed :auto_shutdown_params do
      cmd << configure_application_pool("failure.autoShutdownParams:#{new_resource.auto_shutdown_params}")
    end

    # cpu items
    converge_if_changed :cpu_action do
      cmd << configure_application_pool("cpu.action:#{new_resource.cpu_action}")
    end
    converge_if_changed :cpu_limit do
      cmd << configure_application_pool("cpu.limit:#{new_resource.cpu_limit}")
    end
    converge_if_changed :cpu_reset_interval do
      cmd << configure_application_pool("cpu.resetInterval:#{new_resource.cpu_reset_interval}")
    end
    converge_if_changed :cpu_smp_affinitized do
      cmd << configure_application_pool("cpu.smpAffinitized:#{new_resource.cpu_smp_affinitized}")
    end
    converge_if_changed :smp_processor_affinity_mask do
      cmd << configure_application_pool("cpu.smpProcessorAffinityMask:#{new_resource.smp_processor_affinity_mask.floor}")
    end
    converge_if_changed :smp_processor_affinity_mask_2 do
      cmd << configure_application_pool("cpu.smpProcessorAffinityMask2:#{new_resource.smp_processor_affinity_mask_2.floor}")
    end

    unless current_resource.runtime_version && cmd == "#{appcmd(node)} set config /section:applicationPools"
      converge_by "Configured Application Pool \"#{new_resource}\"" do
        Chef::Log.debug(cmd)
        shell_out!(cmd)
      end
    end

    # Application Pool Identity Settings
    if new_resource.username && new_resource.username != ''
      cmd = default_app_pool_user
      converge_if_changed :username do
        cmd << " \"/[name='#{new_resource.name}'].processModel.userName:#{new_resource.username}\""
      end
      converge_if_changed :password do
        cmd << " \"/[name='#{new_resource.name}'].processModel.password:#{new_resource.password}\""
      end
      if cmd != default_app_pool_user
        converge_by "Configured Application Pool Identity Settings \"#{new_resource}\"" do
          Chef::Log.debug(cmd)
          shell_out!(cmd)
        end
      end
    elsif new_resource.identity_type != 'SpecificUser'
      converge_if_changed :identity_type do
        cmd = "#{appcmd(node)} set config /section:applicationPools"
        cmd << " \"/[name='#{new_resource.name}'].processModel.identityType:#{new_resource.identity_type}\""
        Chef::Log.debug(cmd)
        shell_out!(cmd)
      end
    end
  end

  def default_app_pool_user
    cmd_default = "#{appcmd(node)} set config /section:applicationPools"
    cmd_default << " \"/[name='#{new_resource.name}'].processModel.identityType:SpecificUser\""
  end

  def configure_application_pool(config, add_remove = '')
    " \"/#{add_remove}[name='#{new_resource.name}'].#{config}\""
  end
end

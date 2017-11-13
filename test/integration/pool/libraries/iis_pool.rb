# encoding: utf-8
# frozen_string_literal: true
# check for application pools in IIS
# Usage:
# describe iis_pool('DefaultAppPool') do
#  it { should exist }
#  it { should have_name('DefaultAppPool') }
#  it { should have_queue_length(1000) }
#  it { should be_running }
# end
#
# Note: this is only supported in windows 2012 and later

class IisPool < Inspec.resource(1)
  name 'iis_pool'
  desc 'Tests IIS application pool\'s configuration on windows. Supported in server 2012+ only'
  example "
    describe iis_pool('DefaultAppPool') do
      it { should exist }
      it { should have_name('DefaultAppPool') }
      it { should have_queue_length(1000) }
      is { should be_running }
    end
  "

  def initialize(pool_name)
    @pool_name = pool_name
    @cache = nil

    @pool_provider = PoolProvider.new(inspec)

    # verify that this resource is only supported on Windows
    return skip_resource 'The `iis_pool` resource is not supported on your OS.' unless inspec.os.windows?
  end

  def name
    iis_pool[:name]
  end

  def queue_length
    iis_pool[:queue_length]
  end

  def auto_start?
    iis_pool[:auto_start]
  end

  def enable_32bit_app_on_win64?
    iis_pool[:enable_32bit_app_on_win64]
  end

  def managed_runtime_version
    iis_pool[:managed_runtime_version]
  end

  def managed_runtime_loader
    iis_pool[:managed_runtime_loader]
  end

  def enable_configuration_override?
    iis_pool[:enable_configuration_override]
  end

  def managed_pipeline_mode
    iis_pool[:managed_pipeline_mode]
  end

  def pass_anonymous_token
    iis_pool[:pass_anonymous_token]
  end

  def start_mode
    iis_pool[:start_mode]
  end

  def state
    iis_pool[:state]
  end

  def item_x_path
    iis_pool[:item_x_path]
  end

  def worker_processes
    iis_pool[:worker_processes]
  end

  def identity_type
    iis_pool[:process_model][:identity_type]
  end

  def username
    iis_pool[:process_model][:username]
  end

  def password
    iis_pool[:process_model][:password]
  end

  def periodic_restart_schedule
    iis_pool[:recycling][:periodic_restart][:schedule]
  end

  def exists?
    !iis_pool.nil? && !iis_pool[:name].nil?
  end

  def running?
    iis_pool.nil? ? false : (iis_pool[:state] == 'Started')
  end

  def has_name?(pool_name)
    iis_pool.nil? ? false : iis_pool[:name] == pool_name
  end

  def has_queue_length?(queue_length)
    iis_pool.nil? ? false : iis_pool[:queue_length] == queue_length
  end

  def to_s
    "iis_pool '#{@pool_name}' "
  end

  def iis_pool
    return @cache unless @cache.nil?
    @cache = @pool_provider.iis_pool(@pool_name) unless @pool_provider.nil?
  end
end

class PoolProvider
  attr_reader :inspec

  def initialize(inspec)
    @inspec = inspec
  end

  # want to populate everything using one powershell command here and spit it out as json
  def iis_pool(pool_name)
    command = "Import-Module WebAdministration; Get-Item \"IIS:\\AppPools\\#{pool_name}\" | Select-Object name, queueLength, autoStart, enable32BitAppOnWin64, managedRuntimeVersion, managedRuntimeLoader, enableConfigurationOverride, managedPipelineMode, passAnonymousToken, startMode, state, ItemXPath | ConvertTo-Json"
    cmd = @inspec.command(command)
    command_process_model = "(Get-Item \"IIS:\\AppPools\\#{pool_name}\").processModel | Select-Object identityType, userName, password, loadUserProfile, setProfileEnvironment, logonType, manualGroupMembership, idleTimeout, idleTimeoutAction, maxProcesses, shutdownTimeLimit, startupTimeLimit, pingingEnabled, pingInterval, pingResponseTime, logEventOnProcessModel | ConvertTo-Json"
    cmd_process_model = @inspec.command(command_process_model)
    command_recycling = "(Get-Item \"IIS:\\AppPools\\#{pool_name}\").recycling | Select-Object disallowOverlappingRotation, disallowRotationOnConfigChange, logEventOnRecycle | ConvertTo-Json"
    cmd_recycling = @inspec.command(command_recycling)
    command_recycling_periodic_restart = "(Get-Item \"IIS:\\AppPools\\#{pool_name}\").recycling.periodicRestart | Select-Object memory, privateMemory, requests, time | ConvertTo-Json"
    cmd_recycling_periodic_restart = @inspec.command(command_recycling_periodic_restart)
    command_recycling_period_restart_schedule = "(Get-Item \"IIS:\\AppPools\\#{pool_name}\").recycling.periodicRestart.schedule | Select-Object Collection | ConvertTo-Json"
    cmd_recycling_period_restart_schedule = @inspec.command(command_recycling_period_restart_schedule)
    command_failing = "(Get-Item \"IIS:\\AppPools\\#{pool_name}\").failure | Select-Object loadBalancerCapabilities, orphanWorkerProcess, orphanActionExe, orphanActionParams, rapidFailProtection, rapidFailProtectionInterval, rapidFailProtectionMaxCrashes, autoShudownExe, autoShutdownParams | ConvertTo-Json"
    cmd_failing = @inspec.command(command_failing)
    command_cpu = "(Get-Item \"IIS:\\AppPools\\#{pool_name}\").cpu | Select-Object limit, action, resetInterval, smpAffinitized, smpProcessorAffinityMask, smpProcessorAffinityMask2, processorGroup, numaNodeAssignment, numaNodeAffinityMode | ConvertTo-Json"
    cmd_cpu = @inspec.command(command_cpu)
    command_worker_processes = "(Get-Item \"IIS:\\AppPools\\#{pool_name}\").workerProcesses | Select-Object Collection | ConvertTo-Json"
    cmd_worker_processes = @inspec.command(command_worker_processes)

    begin
      pool = JSON.parse(cmd.stdout)
      pool_process_model = JSON.parse(cmd_process_model.stdout)
      pool_recyling = JSON.parse(cmd_recycling.stdout)
      pool_recycling_periodic_restart = JSON.parse(cmd_recycling_periodic_restart.stdout)
      pool_recycling_period_restart_schedule = JSON.parse(cmd_recycling_period_restart_schedule.stdout)
      pool_failing = JSON.parse(cmd_failing.stdout)
      pool_cpu = JSON.parse(cmd_cpu.stdout)
      pool_worker_processes = JSON.parse(cmd_worker_processes.stdout)
    rescue JSON::ParserError => _e
      return {}
    end

    restart_schedules = []
    pool_recycling_period_restart_schedule['Collection'].each { |schedule| restart_schedules.push(schedule['value']) }

    worker_processes = []
    pool_worker_processes['Collection'].each { |process| worker_processes.push(process_id: process['processId'], handles: process['Handles'], state: process['state'], start_time: process['StartTime']) }

    # map our values to a hash table
    {
      name: pool['name'],
      queue_length: pool['queueLength'],
      auto_start: pool['autoStart'],
      enable_32bit_app_on_win64: pool['enable32BitAppOnWin64'],
      managed_runtime_version: pool['managedRuntimeVersion'],
      managed_runtime_loader: pool['managedRuntimeLoader'],
      enable_configuration_override: pool['enableConfigurationOverride'],
      managed_pipeline_mode: pool['managedPipelineMode'],
      pass_anonymous_token: pool['passAnonymousToken'],
      start_mode: pool['startMode'],
      state: pool['state'],
      item_x_path: pool['ItemXPath'],
      process_model: {
        identity_type: pool_process_model['identityType'],
        username: pool_process_model['userName'],
        password: pool_process_model['password'],
        load_user_profile: pool_process_model['loadUserProfile'],
        set_profile_environment: pool_process_model['setProfileEnvironment'],
        logon_type: pool_process_model['logonType'],
        manual_group_membership: pool_process_model['manualGroupMembership'],
        idle_timeout: "#{pool_process_model['idleTimeout']['Days']}.#{pool_process_model['idleTimeout']['Hours']}:#{pool_process_model['idleTimeout']['Minutes']}:#{pool_process_model['idleTimeout']['Seconds']}",
        idle_timeout_action: pool_process_model['idleTimeoutAction'],
        max_processes: pool_process_model['maxProcesses'],
        shutdown_time_limit: "#{pool_process_model['shutdownTimeLimit']['Days']}.#{pool_process_model['shutdownTimeLimit']['Hours']}:#{pool_process_model['shutdownTimeLimit']['Minutes']}:#{pool_process_model['shutdownTimeLimit']['Second']}",
        startup_time_limit: "#{pool_process_model['startupTimeLimit']['Days']}.#{pool_process_model['startupTimeLimit']['Hours']}:#{pool_process_model['startupTimeLimit']['Minutes']}:#{pool_process_model['startupTimeLimit']['Seconds']}",
        pinging_enabled: pool_process_model['pingingEnabled'],
        ping_interval: "#{pool_process_model['pingInterval']['Days']}.#{pool_process_model['pingInterval']['Hours']}:#{pool_process_model['pingInterval']['Minutes']}:#{pool_process_model['pingInterval']['Seconds']}",
        ping_response_time: "#{pool_process_model['pingResponseTime']['Days']}.#{pool_process_model['pingResponseTime']['Hours']}:#{pool_process_model['pingResponseTime']['Minutes']}:#{pool_process_model['pingResponseTime']['Second']}",
        log_event_on_process_model: pool_process_model['logEventOnProcessModel'],
      },
      recycling: {
        disallow_overlapping_rotation: pool_recyling['disallowOverlappingRotation'],
        disallow_rotation_on_config_change: pool_recyling['disallowRotationOnConfigChange'],
        log_event_on_recycle: pool_recyling['logEventOnRecycle'],
        periodic_restart: {
          memory: pool_recycling_periodic_restart['memory'],
          privateMemory: pool_recycling_periodic_restart['privateMemory'],
          requests: pool_recycling_periodic_restart['requests'],
          time: "#{pool_recycling_periodic_restart['time']['Days']}.#{pool_recycling_periodic_restart['time']['Hours']}:#{pool_recycling_periodic_restart['time']['Minutes']}:#{pool_recycling_periodic_restart['time']['Seconds']}",
          schedule: restart_schedules,
        },
      },
      failing: {
        loadBalancerCapabilities: pool_failing['loadBalancerCapabilities'],
        orphanWorkerProcess: pool_failing['orphanWorkerProcess'],
        orphanActionExe: pool_failing['orphanActionExe'],
        orphanActionParams: pool_failing['orphanActionParams'],
        rapidFailProtection: pool_failing['rapidFailProtection'],
        rapidFailProtectionInterval: "#{pool_failing['rapidFailProtectionInterval']['Days']}.#{pool_failing['rapidFailProtectionInterval']['Hours']}:#{pool_failing['rapidFailProtectionInterval']['Minutes']}:#{pool_failing['rapidFailProtectionInterval']['Seconds']}",
        rapidFailProtectionMaxCrashes: pool_failing['rapidFailProtectionMaxCrashes'],
        autoShudownExe: pool_failing['autoShudownExe'],
        autoShutdownParam: pool_failing['autoShutdownParam'],
      },
      cpu: {
        limit: pool_cpu['limit'],
        action: pool_cpu['action'],
        resetInterval: "#{pool_cpu['resetInterval']['Days']}.#{pool_cpu['resetInterval']['Hours']}:#{pool_cpu['resetInterval']['Minutes']}:#{pool_cpu['resetInterval']['Seconds']}",
        smpAffinitized: pool_cpu['smpAffinitized'],
        smpProcessorAffinityMask: pool_cpu['smpProcessorAffinityMask'],
        smpProcessorAffinityMask2: pool_cpu['smpProcessorAffinityMask2'],
        processorGroup: pool_cpu['processorGroup'],
        numaNodeAssignment: pool_cpu['numaNodeAssignment'],
        numaNodeAffinityMode: pool_cpu['numaNodeAffinityMode'],
      },
      worker_processes: worker_processes,
    }
  end
end

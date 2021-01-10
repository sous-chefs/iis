[back to resource list](https://github.com/sous-chefs/iis#resources)

---

# iis_pool

Creates an application pool in IIS.

## Actions

- `:add` - add a new application pool
- `:config` - apply configuration to an existing application pool
- `:delete` - delete an existing application pool
- `:start` - start a application pool
- `:stop` - stop a application pool
- `:restart` - restart a application pool
- `:recycle` - recycle an application pool

## Properties

### Root

| Name              | Type            | Default     | Required  |  Description                          | Allowed Values |
| ----------------- | --------------- | ----------- | --------- | ------------------------------------ |---------------- |
| `pool_name`       |  String         |             | No        | name property. Specifies the name of the pool to create. We use the resource name if this isn't specified here | |
| `runtime_version` |  String         |             | No        | specifies what .NET version of the runtime to use. | |
| `pipeline_mode`   |  Symbol, String |`Integrated` | No        | specifies what pipeline mode to create the pool with| `:Integrated`, `:Classic` |
| `no_managed_code` |  true, false    | `false`     | No        | allow Unmanaged Code in setting up IIS app pools is shutting down. | |

### Add Items

| Name              | Type            | Default     | Required  |  Description                          | Allowed Values |
| ----------------- | --------------- | ----------- | --------- | ------------------------------------ |---------------- |
| `start_mode`      |  Symbol, String | `:OnDemand` | No        | Specifies the startup type for the application pool | `:OnDemand`, `:AlwaysRunning`|
| `auto_start`      |  true, false    | `true`      | No        | When true, indicates to the World Wide Web Publishing Service (W3SVC) that the application pool should be automatically started when it is created or when IIS is started | |
| `queue_length`    |  Integer        | `1000`      | No        | Indicates to HTTP.sys how many requests to queue for an application pool before rejecting future requests | `:Integrated`, `:Classic` |
| `thirty_two_bit`  |  true, false    | `false`     | No        | set the pool to run in 32 bit mode. | |

### Process Model Items

| Name                      | Type            | Default     | Required  |  Description                          | Allowed Values |
| ------------------------- | --------------- | ----------- | --------- | ------------------------------------ |---------------- |
| `max_processes`           |  Integer        |             | No        | specifies the number of worker processes associated with the pool. | |
| `load_user_profile`       |  true, false    | `false`     | No        | This property is used only when a service starts in a named user account. | |
| `identity_type`           |  Symbol, String |             | No        | the account identity that they app pool will run as | `:SpecificUser`, `:NetworkService`, `:LocalService`, `:LocalSystem`, `:ApplicationPoolIdentity`|
| `username`                |  String         |             | No        | username for the identity for the application pool | |
| `password`                |  String         |             | No        | password for the identity for the application pool is started | |
| `logon_type`              |  Symbol, String |             | No        | Specifies the logon type for the process identity. (For additional information about [logon types](http://msdn.microsoft.com/en-us/library/aa378184%28VS.85%29.aspx), see the LogonUser Function topic on Microsoft's MSDN Web site.) | `:LogonBatch`, `:LogonService`|
| `manual_group_membership` |  true, false    | `false`     | No        | Specifies whether the IIS_IUSRS group Security Identifier (SID) is added to the worker process token. When false, IIS automatically uses an application pool identity as though it were a member of the built-in IIS_IUSRS group, which has access to necessary file and system resources. When true, an application pool identity must be explicitly added to all resources that a worker process requires at runtime | |
| `idle_timeout`            |  String         | `'00:20:00'`| No        | Specifies how long (in minutes) a worker process should run idle if no new requests are received and the worker process is not processing requests. After the allocated time passes, the worker process should request that it be shut down by the WWW service | |
| `idle_timeout_action`     |  Symbol, String |             | No        | Specifies the option of suspending an idle worker process rather than terminating it. | `:Terminate`, `:Suspend`|
| `shutdown_time_limit`     |  String         | `'00:01:30'`| No        | Specifies the time that the W3SVC service waits after it initiated a recycle. If the worker process does not shut down within the shutdownTimeLimit, it will be terminated by the W3SVC service. | |
| `startup_time_limit`      |  String         | `'00:01:30'`| No        | Specifies the time that IIS waits for an application pool to start. If the application pool does not startup within the startupTimeLimit, the worker process is terminated and the rapid-fail protection count is incremented. | |
| `pinging_enabled`         |  true, false    | `true`      | No        | Specifies whether pinging is enabled for the worker process. | |
| `ping_interval`           |  String         | `'00:00:30'`| No        | Specifies the time between health-monitoring pings that the WWW service sends to a worker process | |
| `ping_response_time`      |  String         | `'00:01:30'`| No        | Specifies the time that a worker process is given to respond to a health-monitoring ping. After the time limit is exceeded, the WWW service terminates the worker process | |

### Recycling Items

| Name                                  | Type            | Default     | Required  |  Description                          | Allowed Values |
| ------------------------------------- | --------------- | ----------- | --------- | ------------------------------------ |---------------- |
| `disallow_rotation_on_config_change`  |  true, false    | `false`     | No        | The DisallowRotationOnConfigChange property specifies whether or not the World Wide Web Publishing Service (WWW Service) should rotate worker processes in an application pool when the configuration has changed. | |
| `disallow_overlapping_rotation`       |  true, false    | `false`     | No        | Specifies whether the WWW Service should start another worker process to replace the existing worker process while that process | |
| `recycle_schedule_clear`              |  String         | `false`     | No        | specifies a pool to clear all scheduled recycle times. | |
| `log_event_on_recycle`                |  true, false    | `node['iis']['recycle']['log_events']`| No        | configure IIS to log an event when one or more of the following configured events cause an application pool to recycle (for additional information about [logging events] (<https://technet.microsoft.com/en-us/library/cc771318%28v=ws.10%29.aspx>). | |
| `recycle_after_time`                  |  String         |             | No        | specifies a pool to recycle at regular time intervals, d.hh:mm:ss. | |
| `periodic_restart_schedule`           |  Array, String  |             | No        | schedule a pool to recycle at specific times. | |
| `private_memory`                      |  Integer        |             | No        | specifies the amount of private memory (in kilobytes) after which you want the pool to recycle. | |
| `virtual_memory`                      |  Integer        |             | No        | specifies the amount of virtual memory (in kilobytes) after which you want the pool to recycle. | |

### Failure Items

| Name                                | Type            | Default     | Required  |  Description                          | Allowed Values |
| ----------------------------------- | --------------- | ----------- | --------- | ------------------------------------ |---------------- |
| `load_balancer_capabilities`        |  Symbol, String | `:HttpLevel`| No        | Specifies behavior when a worker process cannot be started, such as when the request queue is full or an application pool is in rapid-fail protection. | `:HttpLevel`, `:TcpLevel`|
| `orphan_worker_process`             |  true, false    | `false`     | No        | Specifies whether to assign a worker process to an orphan state instead of terminating it when an application pool fails. | |
| `orphan_action_exe`                 |  String         |             | No        | Specifies an executable to run when the WWW service orphans a worker process (if the orphanWorkerProcess attribute is set to true). You can use the orphanActionParams attribute to send parameters to the executable |  |
| `orphan_action_params`              |  String         |             | No        | Indicates command-line parameters for the executable named by the orphanActionExe attribute. To specify the process ID of the orphaned process, use %1%. | |
| `rapid_fail_protection`             |  true, false    | `true`      | No        | Setting to true instructs the WWW service to remove from service all applications that are in an application pool | |
| `rapid_fail_protection_interval`    |  String         | `00:05:00`  | No        | Specifies the number of minutes before the failure count for a process is reset | |
| `rapid_fail_protection_max_crashes` |  Integer        | `5`         | No        | Specifies the maximum number of failures that are allowed within the number of minutes specified by the rapidFailProtectionInterval attribute | |
| `no_managedauto_shutdown_exe_code`  |  String         |             | No        | Specifies an executable to run when the WWW service shuts down an application pool | |
| `auto_shutdown_params`              |  String         |             | No        | Specifies command-line parameters for the executable that is specified in the autoShutdownExe attribute | |

### CPU Items

| Name                            | Type            | Default           | Required  |  Description                          | Allowed Values |
| ------------------------------- | --------------- | ----------------- | --------- | ------------------------------------ |---------------- |
| `cpu_action`                    |  Symbol, String | `:NoAction`       | No        | Configures the action that IIS takes when a worker process exceeds its configured CPU limit. The action attribute is configured on a per-application pool basis | `:NoAction`, `:KillW3wp`, `:Throttle`, `:ThrottleUnderLoad`|
| `cpu_limit`                     |  Integer        | `0`               | No        | Configures the maximum percentage of CPU time (in 1/1000ths of one percent) that the worker processes in an application pool are allowed to consume over a period of time as indicated by the resetInterval attribute. If the limit set by the limit attribute is exceeded, an event is written to the event log and an optional set of events can be triggered. | |
| `cpu_reset_interval`            |  String         | `00:05:00`        | No        | sSpecifies the reset period (in minutes) for CPU monitoring and throttling limits on an application pool. When the number of minutes elapsed since the last process accounting reset equals the number specified by this property, IIS resets the CPU timers for both the logging and limit intervals. | |
| `cpu_smp_affinitized`           |  true, false    | `false`           | No        | Specifies whether a particular worker process assigned to an application pool should also be assigned to a given CPU. | |
| `smp_processor_affinity_mask`   |  Float          | `4_294_967_295.0` | No        | Specifies the hexadecimal processor mask for multi-processor computers, which indicates to which CPU the worker processes in an application pool should be bound. Before this property takes effect, the smpAffinitized attribute must be set to true for the application pool. | |
| `smp_processor_affinity_mask_2` |  Float          | `4_294_967_295.0` | No        | Specifies the high-order DWORD hexadecimal processor mask for 64-bit multi-processor computers, which indicates to which CPU the worker processes in an application pool should be bound. Before this property takes effect, the smpAffinitized attribute must be set to true for the application pool. | |

### Environment Variables

| Name                    | Type            | Default     | Required  |  Description                          | Allowed Values |
| ----------------------- | --------------- | ----------- | --------- | ------------------------------------ |---------------- |
| `environment_variables` |  Array, String  |             | No        | Specifies a list of environment variables that will be passed to a worker process when an application is launched. `FOO=BAR` or `['FOO=BAR','HELLO=WORLD']` | |

## Examples

```ruby
# creates a new app pool
iis_pool 'myAppPool_v1_1' do
  runtime_version "2.0"
  pipeline_mode :Classic
  action :add
end
```

[back to resource list](https://github.com/sous-chefs/iis#resources)

---

# iis_manager

Configures the IIS Manager service

## Actions

- `:config` - Change the configuration of the service. Restarts as necessary and sets the service to be automatic and running.

## Properties

| Name                        | Type          | Default | Description                          |
| --------------------------- | ------------- | ------- |  ------------------------------------ |
| `enable_remote_management`  |  true, false  | `true`  | If remote access allowed |
| `log_directory`             |  String       |         | Optional. The directory to write log files to |
| `port`                      |  Integer      | `8172`  | The port the service listens on. |

## Examples

```ruby
iis_manager 'IIS Manager' do
  port                      9090
  enable_remote_management  true
  log_directory             "C:\\CustomPath"
end
```

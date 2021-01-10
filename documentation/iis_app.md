[back to resource list](https://github.com/sous-chefs/iis#resources)

---

# iis_app

Creates an application in IIS.

## Actions

- `:add` - add a new application pool
- `:delete` - delete an existing application pool
- `:config` - configures an existing application pool

## Properties

| Name                | Type     |  Default | Description                                                               |
| ------------------- | -------- | -------- | ------------------------------------------------------------------------- |
| `site_name`         |  String  |          | name property. The name of the site to add this app to. We use the resource name if this isn't specified here. |
| `path`              |  String  | `/`      | The virtual path for this application |
| `application_pool`  |  String  |          | The pool this application belongs to |
| `physical_path`     |  String  |          | The physical path where this app resides. |
| `enabled_protocols` |  String  |          | The enabled protocols that this app provides (http, https, net.pipe, net.tcp, etc) |

## Examples

```ruby
# creates a new app
iis_app 'myApp' do
  path '/v1_1'
  application_pool 'myAppPool_v1_1'
  physical_path "#{node['iis']['docroot']}/testfu/v1_1"
  enabled_protocols 'http,net.pipe'
  action :add
end
```

[back to resource list](https://github.com/sous-chefs/iis#resources)

---

# iis_manager_permission

Set the permissions for user access to the IIS Manager

Requires: Server 2016+

## Actions

- `:config` : Configure the given path to allow only the defined users and groups access. Removes any other principals. This is an idempotent action.

## Properties

| Name          | Type     |  Required| Description                          |
| ------------- | -------- | -------- | ------------------------------------ |
| `config_path` |  String  | No       | Name property. The IIS Manager path to be configured. Usually just the site name. Taken from the `name` attribute if not set, The config_path takes the form of_site_name_/_application_/_application_ (where applications are optional) |
| `users`       |  Array   | No       | Array of users to be allowed access |
| `groups`      |  Array   | No       | Array of groups to be allowed access |

## Examples

```ruby
iis_manager_permission 'Default Web Site' do
  users ['BUILTIN\\Users']
end
```

[back to resource list](https://github.com/sous-chefs/iis#resources)

---

# iis_config_property

Sets an IIS configuration property

## Actions

- `:set` : Sets the property to the given value if it is not already set.
- `:add` : Adds an item to a collection if one doesn't already exist. `filter` should define a collection element. An item will be added if there is no member with a `property` value of `value`.
- `:remove` : Removes a item from a collection if it already exists. `filter` should define a collection element. The item will be removed if there is a member with a `property` value of `value`.

## Properties

| Name                | Type              | Required| Description                                                               |
| ------------------- | ----------------- | ------- | ------------------------------------------------------------------------- |
| `property`          |  String           | Yes     | name property.  The property to be set. Defaults from name. |
| `ps_path`           |  String           | Yes     | Specifies the configuration path. This can be either an IIS configuration path in the format `computer name/webroot/apphost`, or the IIS module path in this format `IIS:\sites\Default Web Site`. |
| `location`          |  String           | No      | The location of the configuration setting. Location tags are frequently used for configuration settings that must be set more precisely than per application or per virtual directory. For example, a setting for a particular file or directory could use a location tag. Location tags are also used if a particular section is locked. In such an instance, the configuration system would have to use a location tag in one of the parent configuration files. |
| `filter`            |  String           | Yes     | Specifies the IIS configuration section or an XPath query that returns a configuration element. |
| `value`             |  String, Integer  | Yes     | The value to set the property to. Either a string or an integer. |
| `extra_add_values`  |  Hash             | No      | If the `add` action requires additional values to be set at creation then supply them in this hash. This property is not idempotent. It is only used when the configuration is created.|

## Examples

```ruby
# Sets up logging
iis_config_property 'directory' do
  ps_path   'MACHINE/WEBROOT/APPHOST'
  filter    'system.applicationHost/sites/siteDefaults/logfile'
  value     'D:\\logs'
end
```

```ruby
# Set XSS-Protection header on all sites
iis_config_property 'Add X-Xss-Protection' do
  ps_path   'MACHINE/WEBROOT/APPHOST'
  filter    'system.webServer/httpProtocol/customHeaders'
  property  'name'
  value     'X-Xss-Protection'
  action    :add
end
iis_config_property 'Set X-Xss-Protection' do
  ps_path   'MACHINE/WEBROOT/APPHOST'
  filter    "system.webServer/httpProtocol/customHeaders/add[@name='X-Xss-Protection']"
  property  'value'
  value     '1; mode=block'
end
```

```ruby
# Set environment variable ASPNETCORE_ENVIRONMENT to Test
# Note we still need to maintain the value via a Set resource
iis_config_property 'Add login/ASPNETCORE_ENVIRONMENT' do
  ps_path           'MACHINE/WEBROOT/APPHOST'
  location          'Default Web site'
  filter            'system.webServer/aspNetCore/environmentVariables'
  property          'name'
  value             'ASPNETCORE_ENVIRONMENT'
  extra_add_values  value: 'Test'
  action            :add
end
iis_config_property 'Set login/ASPNETCORE_ENVIRONMENT' do
  ps_path   'MACHINE/WEBROOT/APPHOST'
  location  'Default Web site'
  filter    "system.webServer/aspNetCore/environmentVariables/environmentVariable[@name='ASPNETCORE_ENVIRONMENT']"
  property  'value'
  value     'Test'
end
```

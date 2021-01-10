[back to resource list](https://github.com/sous-chefs/iis#resources)

---

# iis_config

Runs a config command on your IIS instance.

## Actions

- `:set` - Edit configuration section (appcmd set config)
- `:clear` - Clear the section configuration (appcmd clear config)

## Properties

| Name                | Type     |  Default | Description                                                               |
| ------------------- | -------- | -------- | ------------------------------------------------------------------------- |
| `cfg_cmd`         |  String  |          | name property. What ever command you would pass in after "appcmd.exe set config" We use the resource name if this isn't specified here. |

## Examples

```ruby
# Sets up logging
iis_config "/section:system.applicationHost/sites /siteDefaults.logfile.directory:\"D:\\logs\"" do
    action :set
end
```

```ruby
# Increase file upload size for 'MySite'
iis_config "\"MySite\" /section:requestfiltering /requestlimits.maxallowedcontentlength:50000000" do
  action :set
end
```

```ruby
# Set IUSR username and password authentication
iis_config "\"MyWebsite/aSite\" -section:system.webServer/security/authentication/anonymousAuthentication /enabled:\"True\" /userName:\"IUSR_foobar\" /password:\"p@assword\" /commit:apphost" do
  action :set
end
```

```ruby
# Authenticate with application pool
iis_config "\"MyWebsite/aSite\" -section:system.webServer/security/authentication/anonymousAuthentication /enabled:\"True\" /userName:\"\" /commit:apphost" do
   action :set
end
```

```ruby
# Loads an array of commands from the node
cfg_cmds = node['iis']['cfg_cmd']
cfg_cmds.each do |cmd|
    iis_config "#{cmd}" do
        action :set
    end
end
```

```ruby
# Add static machine key at site level
iis_config "MySite /commit:site /section:machineKey /validation:AES /validationKey:AAAAAA /decryptionKey:ZZZZZ" do
  action :set
end
```

```ruby
# Remove machine key
iis_config "MySite /commit:site /section:machineKey" do
  action :clear
end
```

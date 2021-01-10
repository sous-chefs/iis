[back to resource list](https://github.com/sous-chefs/iis#resources)

---

# iis_vdir

Allows easy management of IIS virtual directories (i.e. vdirs).

## Actions

- `:add` - add a new virtual directory
- `:delete` - delete an existing virtual directory
- `:config` - configure a virtual directory

## Properties

| Name                  | Type            |  Default    | Description                                                               | Allowed Values |
| --------------------- | --------------- | ----------- | ------------------------------------------------------------------------- |--- |
| `application_name`    |  String         |             | name property. This is the name of the website or site + application you are adding it to. | |
| `path`                |  String         |             | The virtual directory path on the site. | |
| `physical_path`       |  String         |             | The physical path of the virtual directory on the disk. | |
| `username`            |  String         |             | The username required to logon to the physical_path. If set to "" will clear username and password.| |
| `password`            |  String         |             | The password required to logon to the physical_path.| |
| `logon_method`        |  Symbol, String | `:ClearText`| The method used to logon. For more information on these types, see [LogonUser Function](http://msdn2.microsoft.com/en-us/library/aa378184.aspx)|`:Interactive`, `:Batch`, `:Network`, `:ClearText` |
| `allow_sub_dir_config`|  true, false    | `true`      | Boolean that specifies whether or not the Web server will look for configuration files located in the subdirectories of this virtual directory. Setting this to false can improve performance on servers with very large numbers of web.config files, but doing so prevents IIS configuration from being read in subdirectories. | |

## Examples

```ruby
# add a virtual directory to default application
iis_vdir 'Default Web Site/' do
  action :add
  path '/Content/Test'
  physical_path 'C:\wwwroot\shared\test'
end
```

```ruby
# add a virtual directory to an application under a site
iis_vdir 'Default Web Site/my application' do
  action :add
  path '/Content/Test'
  physical_path 'C:\wwwroot\shared\test'
end
```

```ruby
# adds a virtual directory to default application which points to a smb share. (Remember to escape the "\"'s)
iis_vdir 'Default Web Site/' do
  action :add
  path '/Content/Test'
  physical_path '\\\\sharename\\sharefolder\\1'
end
```

```ruby
# configure a virtual directory to have a username and password
iis_vdir 'Default Web Site/' do
  action :config
  path '/Content/Test'
  username 'domain\myspecialuser'
  password 'myspecialpassword'
end
```

```ruby
# delete a virtual directory from the default application
iis_vdir 'Default Web Site/' do
  action :delete
  path '/Content/Test'
end
```

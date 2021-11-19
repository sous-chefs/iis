[back to resource list](https://github.com/sous-chefs/iis#resources)

---

# iis_site

Allows for easy management of IIS virtual sites.

## Actions

- `:add` - add a new virtual site
- `:config` - apply configuration to an existing virtual site
- `:delete` - delete an existing virtual site
- `:start` - start a virtual site
- `:stop` - stop a virtual site
- `:restart` - restart a virtual site

## Properties

| Name                | Type            |  Default | Description                                                               | Allowed Values |
| ------------------- | --------------- | -------- | ------------------------------------------------------------------------- |--- |
| `site_name`         |  String         |          | name property. Specify the name of the site | |
| `site_id`           |  Integer        |          | if not given IIS generates a unique ID for the site | |
| `path`              |  String         |          | IIS will create a root application and a root virtual directory mapped to this specified local pathq| |
| `protocol`          |  Symbol, String |          | Protocol type the site should respond.| `:http`, `:https`, `:ftp`|
| `port`              |  Integer        | `80`     | port site will listen on.| |
| `host_header`       |  String         |          | host header (also known as domains or host names) the site should map to.| |
| `bindings`          |  String         |          | Advanced options to configure the information required for requests to communicate with a Web site. See [iis bindings](http://www.iis.net/configreference/system.applicationhost/sites/site/bindings/binding) for parameter format. When binding is used, port protocol and host_header should not be used..| |
| `application_pool`  |  String         |          | set the application pool of the site.| |
| `options`           |  String         |          | additional options to configure the site.  Such as `"-logDir"`, `"-limits"`, `"-ftpServer"`, `"-applicationDefaults.preloadEnabled:True"`. This can be anything that you would normally add to a appcmd. This only runs during `add` since it isn't idempotent| |
| `log_directory`     |  String         |          | specifies the logging directory, where the log file and logging-related support files are stored.| |
| `log_period`        |  Symbol, String | `:Daily` | specifies how often iis creates a new log file.| `:Daily`, `:Hourly`, `:MaxSize`, `:Monthly`, `:Weekly`|
| `log_truncsize`     |  Integer        |`1048576` | specifies the maximum size of the log file (in bytes) after which to create a new log file.| |

## Examples

```ruby
# stop and delete the default site
iis_site 'Default Web Site' do
  action [:stop, :delete]
end
```

```ruby
# create and start a new site that maps to
# the physical location C:\inetpub\wwwroot\testfu
# first the physical location must exist
directory "#{node['iis']['docroot']}/testfu" do
  action :create
end

# now create and start the site (note this will use the default application pool which must exist)
iis_site 'Testfu Site' do
  protocol :http
  port 80
  path "#{node['iis']['docroot']}/testfu"
  action [:add,:start]
end
```

```ruby
# do the same but map to testfu.chef.io domain
# first the physical location must exist
directory "#{node['iis']['docroot']}/testfu" do
  action :create
end

# now create and start the site (note this will use the default application pool which must exist)
iis_site 'Testfu Site' do
  protocol :http
  port 80
  path "#{node['iis']['docroot']}/testfu"
  host_header "testfu.chef.io"
  action [:add,:start]
end
```

```ruby
# create and start a new site that maps to
# the physical C:\inetpub\wwwroot\testfu
# first the physical location must exist
directory "#{node['iis']['docroot']}/testfu" do
  action :create
end

# also adds bindings to http and https
# binding http to the ip address 10.12.0.136,
# the port 80, and the host header www.domain.com
# also binding https to any ip address,
# the port 443, and the host header www.domain.com
# now create and start the site (note this will use the default application pool which must exist)
iis_site 'FooBar Site' do
  bindings "http/10.12.0.136:80:www.domain.com,https/*:443:www.domain.com"
  path "#{node['iis']['docroot']}/testfu"
  action [:add,:start]
end
```

```ruby
# create a site with preloadEnabled enabled
iis_site 'mysite.com' do
  protocol :http
  port 80
  path "#{node['iis']['docroot']}\dataverify"
  application_pool 'dataverify.com'
  options "-applicationDefaults.preloadEnabled:True"
  action [:add, :start, :config]
end
```

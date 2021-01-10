# iis Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/iis.svg?style=flat)](https://supermarket.chef.io/cookbooks/iis)
[![CI State](https://github.com/sous-chefs/iis/workflows/ci/badge.svg)](https://github.com/sous-chefs/iis/actions?query=workflow%3Aci)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

## Description

Installs and configures Microsoft Internet Information Services (IIS) 7.0 and later

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook maintainers working together to maintain important cookbooks. If you’d like to know more please visit [sous-chefs.org](https://sous-chefs.org/) or come chat with us on the Chef Community Slack in [#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Requirements

### Platforms

- Windows Server 2016
- Windows Server 2019

### Chef

- Chef 12.14+

### Cookbooks

- windows if running on chef < 16

## Attributes

- `node['iis']['home']` - IIS main home directory. default is `%WINDIR%\System32\inetsrv`
- `node['iis']['conf_dir']` - location where main IIS configs lives. default is `%WINDIR%\System32\inetsrv\config`
- `node['iis']['pubroot']` - . default is `%SYSTEMDRIVE%\inetpub`
- `node['iis']['docroot']` - IIS web site home directory. default is `%SYSTEMDRIVE%\inetpub\wwwroot`
- `node['iis']['cache_dir']` - location of cached data. default is `%SYSTEMDRIVE%\inetpub\temp`

## Resources

- [iis_app](https://github.com/sous-chefs/iis/tree/master/documentation/iis_app.md)
- [iis_config_property](https://github.com/sous-chefs/iis/tree/master/documentation/iis_config_property.md)
- [iis_config](https://github.com/sous-chefs/iis/tree/master/documentation/iis_config.md)
- [iis_install](https://github.com/sous-chefs/iis/tree/master/documentation/iis_install.md)
- [iis_manager](https://github.com/sous-chefs/iis/tree/master/documentation/iis_manager.md)
- [iis_manager_permission](https://github.com/sous-chefs/iis/tree/master/documentation/iis_manager_permission.md)
- [iis_module](https://github.com/sous-chefs/iis/tree/master/documentation/iis_module.md)
- [iis_pool](https://github.com/sous-chefs/iis/tree/master/documentation/iis_pool.md)
- [iis_root](https://github.com/sous-chefs/iis/tree/master/documentation/iis_root.md)
- [iis_section](https://github.com/sous-chefs/iis/tree/master/documentation/iis_section.md)
- [iis_site](https://github.com/sous-chefs/iis/tree/master/documentation/iis_site.md)
- [iis_vdir](https://github.com/sous-chefs/iis/tree/master/documentation/iis_vdir.md)

## Recipies

These recipies still exist but are highly likely to be removed in future major releases of this cookbook.

### default recipe

Installs and configures IIS 7.0/7.5/8.0 using the default configuration.

### mod_* recipes

This cookbook also contains recipes for installing individual IIS modules (extensions). These recipes can be included in a node's run_list to build the minimal desired custom IIS installation.

- `mod_aspnet` - installs ASP.NET runtime components
- `mod_aspnet45` - installs ASP.NET 4.5 runtime components
- `mod_auth_basic` - installs Basic Authentication support
- `mod_auth_windows` - installs Windows Authentication (authenticate clients by using NTLM or Kerberos) support
- `mod_compress_dynamic` - installs dynamic content compression support. _PLEASE NOTE_ - enabling dynamic compression always gives you more efficient use of bandwidth, but if your server's processor utilization is already very high, the CPU load imposed by dynamic compression might make your site perform more slowly.
- `mod_compress_static` - installs static content compression support
- `mod_ftp` - installs FTP service
- `mod_iis6_metabase_compat` - installs IIS 6 Metabase Compatibility component.
- `mod_isapi` - installs ISAPI (Internet Server Application Programming Interface) extension and filter support.
- `mod_logging` - installs and enables HTTP Logging (logging of Web site activity), Logging Tools (logging tools and scripts) and Custom Logging (log any of the HTTP request/response headers, IIS server variables, and client-side fields with simple configuration) support
- `mod_management` - installs Web server Management Console which supports management of local and remote Web servers
- `mod_security` - installs URL Authorization (Authorizes client access to the URLs that comprise a Web application), Request Filtering (configures rules to block selected client requests) and IP Security (allows or denies content access based on IP address or domain name) support.
- `mod_tracing` - installs support for tracing ASP.NET applications and failed requests.

Note: Not every possible IIS module has a corresponding recipe. The foregoing recipes are included for convenience, but users may also place additional IIS modules that are installable as Windows features into the `node['iis']['components']` array.

## Contributors

This project exists thanks to all the people who [contribute.](https://opencollective.com/sous-chefs/contributors.svg?width=890&button=false)

### Backers

Thank you to all our backers!

![https://opencollective.com/sous-chefs#backers](https://opencollective.com/sous-chefs/backers.svg?width=600&avatarHeight=40)

### Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website.

![https://opencollective.com/sous-chefs/sponsor/0/website](https://opencollective.com/sous-chefs/sponsor/0/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/1/website](https://opencollective.com/sous-chefs/sponsor/1/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/2/website](https://opencollective.com/sous-chefs/sponsor/2/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/3/website](https://opencollective.com/sous-chefs/sponsor/3/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/4/website](https://opencollective.com/sous-chefs/sponsor/4/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/5/website](https://opencollective.com/sous-chefs/sponsor/5/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/6/website](https://opencollective.com/sous-chefs/sponsor/6/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/7/website](https://opencollective.com/sous-chefs/sponsor/7/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/8/website](https://opencollective.com/sous-chefs/sponsor/8/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/9/website](https://opencollective.com/sous-chefs/sponsor/9/avatar.svg?avatarHeight=100)

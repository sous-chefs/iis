# iis Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/iis.svg?style=flat)](https://supermarket.chef.io/cookbooks/iis)
[![CI State](https://github.com/sous-chefs/iis/workflows/ci/badge.svg)](https://github.com/sous-chefs/iis/actions?query=workflow%3Aci)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

## Description

Installs and configures Microsoft Internet Information Services (IIS) 7.0 and later

## Migration

This cookbook is now resource-only.

- Root `recipes/` and `attributes/` are removed in favor of explicit custom resource usage.
- Legacy recipe migrations and attribute replacements are documented in [migration.md](migration.md).
- Platform and installation constraints are documented in [LIMITATIONS.md](LIMITATIONS.md).

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook maintainers working together to maintain important cookbooks. If you’d like to know more please visit [sous-chefs.org](https://sous-chefs.org/) or come chat with us on the Chef Community Slack in [#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Requirements

### Platforms

- Windows
- See [LIMITATIONS.md](LIMITATIONS.md) for the current IIS support envelope and Windows-only constraints.

### Chef

- Chef Infra Client 15.3+

## Defaults

This cookbook no longer exposes node attributes.

- Set installation and configuration choices directly on resources such as `iis_install`, `iis_site`, `iis_pool`, and `iis_module`.
- When you need the conventional IIS paths in Ruby code, use `IISCookbook::Constants.iis_home`, `iis_conf_dir`, `iis_pubroot`, `iis_docroot`, and `iis_cache_dir`.

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

## Usage

```ruby
iis_install 'install IIS' do
  additional_components %w(IIS-DefaultDocument IIS-StaticContent)
  start_iis true
end
```

```ruby
iis_site 'Default Web Site' do
  action [:stop, :delete]
end

iis_pool 'DefaultAppPool' do
  action [:stop, :delete]
end
```

```ruby
iis_install 'install module prerequisites' do
  additional_components %w(IIS-ASPNET45 IIS-ISAPIFilter IIS-ISAPIExtensions)
  start_iis true
end
```

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

# IIS Migration Guide

This release removes the cookbook's root `attributes/` and `recipes/` directories and expects
consumers to use custom resources directly.

## Breaking changes

- `include_recipe 'iis'` and `include_recipe 'iis::*'` are no longer supported.
- `node['iis']` attributes are no longer part of the public API.
- Default install behavior, module enablement, and default-site removal must now be expressed with
  resources in your own wrapper cookbook.

## Attribute replacements

Use explicit resource properties instead of cookbook attributes:

| Removed attribute | Replacement |
| --- | --- |
| `node['iis']['components']` | `iis_install additional_components:` |
| `node['iis']['source']` | `iis_install source:` |
| `node['iis']['windows_feature_install_method']` | `iis_install install_method:` or `iis_manager install_method:` |
| `node['iis']['recycle']['log_events']` | `iis_pool log_event_on_recycle:` |

The conventional IIS paths remain available to Ruby code through `IISCookbook::Constants`:

- `iis_home`
- `iis_conf_dir`
- `iis_pubroot`
- `iis_docroot`
- `iis_cache_dir`

## Recipe replacements

### Default install

```ruby
iis_install 'install IIS' do
  start_iis true
end
```

### Remove the default site and pool

```ruby
iis_site 'Default Web Site' do
  action [:stop, :delete]
end

iis_pool 'DefaultAppPool' do
  action [:stop, :delete]
end
```

### Replace legacy `mod_*` recipes

Use `iis_install` with the Windows feature components you actually need, then add any related
configuration resources explicitly.

```ruby
iis_install 'install ASP.NET and ISAPI support' do
  additional_components %w(
    NetFx4Extended-ASPNET45
    IIS-NetFxExtensibility45
    IIS-ASPNET45
    IIS-ISAPIFilter
    IIS-ISAPIExtensions
  )
  start_iis true
end
```

For authentication-related legacy recipes, unlock the relevant sections directly:

```ruby
iis_section 'unlock basic auth settings' do
  section 'system.webServer/security/authentication/basicAuthentication'
  action :unlock
end
```

## Test cookbook examples

The repository's supported examples now live under `test/cookbooks/test/recipes/`:

- `default.rb`
- `disable_default.rb`
- `module.rb`
- `pool.rb`
- `site.rb`
- `site_powershell.rb`

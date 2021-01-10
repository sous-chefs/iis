[back to resource list](https://github.com/sous-chefs/iis#resources)

---

# iis_section

Allows for the locking/unlocking of sections ([listed here](http://www.iis.net/configreference) or via the command `appcmd list config \"\" /config:* /xml`)

This is valuable to allow the `web.config` of an individual application/website control it's own settings.

## Actions

- `section`: The name of the section to lock.
- `site`: The name of the site you want to lock or unlock a section for.
- `application_path`: The path to the application you want to lock or unlock a section for.

## Properties

| Name                | Type     |  Default | Description                                                               |
| ------------------- | -------- | -------- | ------------------------------------------------------------------------- |
| `section`           |  String  |          | The name of the section to lock. |
| `site`              |  String  | `/`      | The name of the site you want to lock or unlock a section for |
| `application_path`  |  String  |          | The path to the application you want to lock or unlock a section for.|

## Examples

```ruby
# Sets the IIS global windows authentication to be locked globally
iis_section 'locks global configuration of windows auth' do
  section 'system.webServer/security/authentication/windowsAuthentication'
  action :lock
end
```

```ruby
# Sets the IIS global Basic authentication to be locked globally
iis_section 'locks global configuration of Basic auth' do
  section 'system.webServer/security/authentication/basicAuthentication'
  action :lock
end
```

```ruby
# Sets the IIS global windows authentication to be unlocked globally
iis_section 'unlocked web.config globally for windows auth' do
  action :unlock
  section 'system.webServer/security/authentication/windowsAuthentication'
end
```

```ruby
# Sets the IIS global Basic authentication to be unlocked globally
iis_section 'unlocked web.config globally for Basic auth' do
  action :unlock
  section 'system.webServer/security/authentication/basicAuthentication'
end
```

```ruby
# Sets the static content section for default web site and root to unlocked
iis_section 'unlock staticContent of default web site' do
  section 'system.webServer/staticContent'
  site 'Default Web Site'
  action :unlock
end
```

```ruby
# Sets the static content section for test_app under default website and root to be unlocked
iis_section 'unlock staticContent of default web site' do
  section 'system.webServer/staticContent'
  site 'Default Web Site'
  application_path '/test_app'
  action :unlock
end
```

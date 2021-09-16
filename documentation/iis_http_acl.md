[back to resource list](https://github.com/sous-chefs/iis#resources)

---

# iis_http_acl

Sets the Access Control List for an http URL to grant non-admin accounts permission to open HTTP endpoints.

## Actions

- `:create` - creates or updates the ACL for a URL.
- `:delete` - deletes the ACL from a URL.

## Properties

- `url` - the name of the url to be created/deleted.
- `sddl` - the DACL string configuring all permissions to URL. Mandatory for create if user is not provided. Can't be use with `user`.
- `user` - the name (domain\user) of the user or group to be granted permission to the URL. Mandatory for create if sddl is not provided. Can't be use with `sddl`. Only one user or group can be granted permission so this replaces any previously defined entry. If you receive a parameter error your user may not exist.

## Examples

```ruby
iis_http_acl 'http://+:50051/' do
    user 'pc\\fred'
end
```

```ruby
# Grant access to users "NT SERVICE\WinRM" and "NT SERVICE\Wecsvc" via sddl
iis_http_acl 'http://+:5985/' do
  sddl 'D:(A;;GX;;;S-1-5-80-569256582-2953403351-2909559716-1301513147-412116970)(A;;GX;;;S-1-5-80-4059739203-877974739-1245631912-527174227-2996563517)'
end
```

```ruby
iis_http_acl 'http://+:50051/' do
    action :delete
end
```

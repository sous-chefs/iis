[back to resource list](https://github.com/sous-chefs/iis#resources)

---

# iis_module

Manages modules globally or on a per site basis.

## Actions

- `:add` - add a new module
- `:delete` - delete a module
- `:install` - install a native module from the filesystem (.dll)
- `:uninstall` - uninstall a native module

## Properties

| Name            | Type          | Default | Description                          |
| --------------- | ------------- | ------- |  ------------------------------------ |
| `module_name`   |  String       |         | name property. The name of the module to add or delete |
| `type`          |  String       |         | The type of module |
| `precondition`  |  true, false  |         | precondition for module |
| `application`   |  String       |         | The application or site to add the module to |
| `add`           |  String       | `false` | Whether the module you install has to be globally added |
| `image`         |  String       |         | Location of the DLL of the module to install |

## Examples

```ruby
# Adds a module called "My 3rd Party Module" to mySite/
iis_module "My 3rd Party Module" do
  application "mySite/"
  precondition "bitness64"
  action :add
end
```

```ruby
# Adds a module called "MyModule" to all IIS sites on the server
iis_module "MyModule"
```

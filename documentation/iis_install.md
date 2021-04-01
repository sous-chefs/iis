[back to resource list](https://github.com/sous-chefs/iis#resources)

---

# iis_install

Simple resource to install the IIS feature

## Actions

- `:install`

## Properties

| Name                    | Type     |  Required| Description                          |
| ----------------------- | -------- | -------- | ------------------------------------ |
| `source`                |  String  | No       | Source to install the features from. |
| `additional_components` |  Array   | No       | Features of IIS to install |
| `install_method`        |  :windows_feature_dism, :windows_feature_powershell | No | install_method to be used to any windows_features  resources. Default is :windows_feature_dism |

## Examples

```ruby
# creates a new app
iis_install 'install IIS'
```

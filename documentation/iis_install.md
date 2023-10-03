[back to resource list](https://github.com/sous-chefs/iis#resources)

---

# iis_install

Simple resource to install the IIS feature

## Actions

- `:install`

## Properties

| Name                    | Type           |  Required| Description                          |
| ----------------------- | -------------- | -------- | ------------------------------------ |
| `source`                |  String        | No       | Source to install the features from. |
| `additional_components` |  String,Array  | No       | Features of IIS to install |
| `install_method`        |  String, Symbol| No       | install_method to be used to any windows_features  resources. Default is :windows_feature_dism. Options are :windows_feature_dism, :windows_feature_powershell |
| `start_iis`             | true, false    | No       | Controls whether the W3WVC service is enabled and started. Default is false

## Examples

```ruby
# creates a new app
iis_install 'install IIS'
```

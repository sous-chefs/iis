## Future

* `:modify` action for iis_site
* resource/provider for managing IIS virtual directories
* IIS 6.0 support

## 1.1.2

* add config resource attribute :returns to accept non-zero return codes.
* add support for configuring app pool identity
* add attribute to install IIS with alternative list of components

## 1.1.1:

* Modified the regex in pool:load_current_resource to search for the full app pool name, rather then the start.

## 1.1.0:

* [COOK-1012] - support adding apps
* [COOK-1028] - support for config command
* [COOK-1041] - fix removal in app pools
* [COOK-835] - add app pool management
* [COOK-950] - documentation correction for version of IIS/OS

## 1.0.2:

* Ruby 1.9 compat fixes
* ensure carriage returns are removed before applying regex

## 1.0.0:

* [COOK-718] initial release

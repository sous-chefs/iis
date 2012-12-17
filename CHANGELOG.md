## Future

* `:modify` action for iis_site
* resource/provider for managing IIS virtual directories
* IIS 6.0 support

## v1.3.2:

* [COOK-1251] - Fix LWRP "NotImplementedError"

## v1.3.0:

* [COOK-1301] - Add a recycle action to the iis_pool resource
* [COOK-1665] - app pool identity and new node[iis][component] attribute
* [COOK-1666] - Recipe to remove default site and app pool
* [COOK-1858] - Recipe misspelled

## v1.2.0:

* [COOK-1061] - `iis_site` doesn't allow setting the pool
* [COOK-1078] - handle advanced bindings
* [COOK-1283] - typo on pool
* [COOK-1284] - install iis application initialization
* [COOK-1285] - allow multiple host_header, port and protocol
* [COOK-1286] - allow directly setting which app pool on site creation
* [COOK-1449] - iis pool regex returns true if similar site exists
* [COOK-1647] - mod_ApplicationInitialization isn't RC

## v1.1.0:

* [COOK-1012] - support adding apps
* [COOK-1028] - support for config command
* [COOK-1041] - fix removal in app pools
* [COOK-835] - add app pool management
* [COOK-950] - documentation correction for version of IIS/OS

## v1.0.2:

* Ruby 1.9 compat fixes
* ensure carriage returns are removed before applying regex

## v1.0.0:

* [COOK-718] initial release

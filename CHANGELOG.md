IIS Cookbook CHANGELOG
======================
This file is used to list changes made in each version of the #{cookbook.name} cookbook.


v1.5.2
------
### Bug
- **[COOK-3232](https://tickets.opscode.com/browse/COOK-3232)** - Allow `iis_app` resource `:config` action with a virtual path

v1.5.0
------
### Improvement

- [COOK-2370]: add MVC2, escape `application_pool` and add options for
  recycling
- [COOK-2694]: update iis documentation to show that Windows 2012 and
  Windows 8 are supported

### Bug

- [COOK-2325]: `load_current_resource` does not load state of pool
  correctly, always sets running to false
- [COOK-2526]: Installing IIS after .NET framework will leave
  installation in non-working state
- [COOK-2596]: iis cookbook fails with indecipherable error if EULA
  not accepted

v1.4.0
------
* [COOK-2181] -Adding full module support to iis cookbook

v1.3.6
------
* [COOK-2084] - Add support for additional options during site creation
* [COOK-2152] - Add recipe for IIS6 metabase compatibility

v1.3.4
------
* [COOK-2050] - IIS cookbook does not have returns resource defined

v1.3.2
------
* [COOK-1251] - Fix LWRP "NotImplementedError"

v1.3.0
------
* [COOK-1301] - Add a recycle action to the iis_pool resource
* [COOK-1665] - app pool identity and new node[iis][component] attribute
* [COOK-1666] - Recipe to remove default site and app pool
* [COOK-1858] - Recipe misspelled

v1.2.0
------
* [COOK-1061] - `iis_site` doesn't allow setting the pool
* [COOK-1078] - handle advanced bindings
* [COOK-1283] - typo on pool
* [COOK-1284] - install iis application initialization
* [COOK-1285] - allow multiple host_header, port and protocol
* [COOK-1286] - allow directly setting which app pool on site creation
* [COOK-1449] - iis pool regex returns true if similar site exists
* [COOK-1647] - mod_ApplicationInitialization isn't RC

v1.1.0
------
* [COOK-1012] - support adding apps
* [COOK-1028] - support for config command
* [COOK-1041] - fix removal in app pools
* [COOK-835] - add app pool management
* [COOK-950] - documentation correction for version of IIS/OS

v1.0.2
------
* Ruby 1.9 compat fixes
* ensure carriage returns are removed before applying regex

v1.0.0
------
* [COOK-718] initial release

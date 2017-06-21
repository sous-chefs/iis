# iis Cookbook CHANGELOG

This file is used to list changes made in each version of the iis cookbook.

## 6.7.2 (2017-06-21)
- Fix FTP issue with iis_site resource

## 6.7.1 (2017-06-09)
- [Fix issue with guard clause missing on check](https://github.com/chef-cookbooks/iis/pull/378)

## 6.7.0 (2017-06-09)
- [Fix idempotency in `iis_app`, `iis_root`, and `iis_vdir`](https://github.com/chef-cookbooks/iis/pull/375)

## 6.6.0 (2017-06-01)
- Convert `iis_module` to a custom resource

## 6.5.3 (2017-05-17)
- Refactor `iis_vdir` name property to `application_name`
- Resolves a bug in iis_vdir also adds more liberty in config

## 6.5.2 (2017-05-15)
- [Update iis_vdir name to not require a trailing /](https://github.com/chef-cookbooks/iis/pull/363)
- [Fix iis_pool identity_type issue](https://github.com/chef-cookbooks/iis/pull/362)

## 6.5.1 (2017-05-12)
- [iis_pool is not Idempotent](https://github.com/chef-cookbooks/iis/issues/354)
- Fix whitespace in `iis_pool` name

## 6.5.0 (2017-05-10)
- Convert `iis_root` to a custom resource
- [uninitialized constant Chef::Resource::IisRoot](https://github.com/chef-cookbooks/iis/issues/333)
- [mime types are not deleted](https://github.com/chef-cookbooks/iis/issues/321)
- [iis_root errors on 'duplicate collection entry of type 'mimeMap'](https://github.com/chef-cookbooks/iis/issues/199)

## 6.4.1 (2017-05-05)
- [fix bug with start having ! in front](https://github.com/chef-cookbooks/iis/pull/349)
 
## 6.4.0 (2017-05-04)
- Convert `iis_section` to a custom resource
- Resolve issue with `iis_pool`

## 6.3.1 (2017-04-26)

- [Fix multiple issues with ~FC023](https://github.com/chef-cookbooks/iis/pull/341)

## 6.3.0 (2017-04-24)

- Convert `iis_pool` to a custom resource
- Convert `iis_vdir` to a custom resource
- Bug fix for `log` function change to `Chef::Log`

## 6.2.0 (2017-04-18)

- Convert `iis_site` to a custom resource

## 6.1.0 (2017-04-14)

- Convert `iis_config` to a custom resource

## 6.0.1 (2017-04-07)

- Fix undefined method `site_identifier` with iis_app resource.

## 6.0.0 (2017-04-06)

- Rewrite of `iis_app` resource to use custom resources.
- Addition of testing for `iis_app` resource.

## 5.1.0 (2017-03-20)

- Require at least windows 2.0 cookbook
- Run integration testing in Appveyer
- Switched testing to Inspec from pester/ServerSpec combo
- Removed the empty iis_test cookbook

## 5.0.8 (2017-03-13)

- [iis-root default_documents broke from last fix](#306)

## 5.0.7 (2017-03-07)

- [iis-root default_documents deleted every chef run](#306)

## 5.0.6 (2017-02-24)

- [iis_version is not evaluated properly on if statement](#308)

## 5.0.5 (2016-11-21)

- [Fixed no_managed_code idempotency](#301)

## 5.0.4 (2016-10-11)

- fixed adding an app pool to a site - This fixes a bug where adding an app pool to a site causes an error. This was using the 'add app' where we are working with a site and the syntax is slightly different according to this [documentation](https://technet.microsoft.com/en-us/library/cc732992%28v=ws.10%29.aspx).

## 5.0.3 (2016-10-10)

- Log event on recycle - This allows you to specify which events you want to log on recycle. This also changes this so that it defaults to the standard nothing, which means you will need to add this attribute if you are depending on it.

## 5.0.2 (2016-10-07)

- [Minor over oversight in IIS::mod_aspnet 5.0.1](#296)
- [IIS Pool resource thirty_two_bit false doesn't](#292)

## 5.0.1 (2016-09-21)

- Fix mod_management to include dependencies (#293)

## 5.0.0 (2016-09-06)

- Adding 2k12 version flag to the windows_feature resource (#291)
- Testing updates
- Avoid deprecation warnings in the specs
- Require Chef 12+

## 4.2.0 (2016-08-09)

- Feature pool recycle virtual memory (#288)

## v4.1.10 (2016-06-29)

- Resolves [Issue with error 50 when installing mod_aspnet](https://github.com/chef-cookbooks/iis/issues/285)

## v4.1.9 (2016-06-26)

- Resolves [Add deprecation warnings for iis_config in 4.2](https://github.com/chef-cookbooks/iis/issues/284)
- Resolves [iis_pool is not idempotent when recycle_at_time is specified and is not changed](https://github.com/chef-cookbooks/iis/issues/279)

## v4.1.8 (2016-04-15)

- Fixed smp_processor_affinity_mask throwing deprecation warnings
- Added additional chefspec tests
- Updated testing dependencies to the latests
- Disabled FC059 rule for now

## v4.1.7 (2016-03-25)

- Resolves [smp_processor_affinity_mask is wrong value type](https://github.com/chef-cookbooks/iis/issues/266)
- Resolves [Not a valid unsigned integer](https://github.com/chef-cookbooks/iis/issues/261)
- Resolves [Deprecated features used](https://github.com/chef-cookbooks/iis/issues/259)
- Resolves [Deprecated feature used, fix before chef 13](https://github.com/chef-cookbooks/iis/issues/253)
- Resolves [iis_site :config action not idempotent (Windows 2012 R2/IIS 8.5)](https://github.com/chef-cookbooks/iis/issues/249)
- Resolves [Can't set recycle_at_time to default](https://github.com/chef-cookbooks/iis/issues/247)

## v4.1.6 (2016-02-01)

- Resolves issues with [Unable to set app pool to be "No Managed Code"](https://github.com/chef-cookbooks/iis/issues/240)
- Resolves [Add_mime_maps is throwing compile error](https://github.com/chef-cookbooks/iis/issues/238)
- Resolves [FATAL: NameError: iis_root "xxx" had an error: NameError: No resource, method, or local variable named `was _updated' for`LWRP provider iis_root from cookbook iis](https://github.com/chef-cookbooks/iis/issues/236)

## v4.1.5 (2015-11-18)

- Resolves issues with `iis_root` [#222](https://github.com/chef-cookbooks/iis/issues/222)

## v4.1.4 (2015-11-2)

- Re-added functionality for iis_pool auto_start, this was a breaking change

## v4.1.3 (2015-10-30)

- Resolves Robucop issues
- Bug Fix for [#217](https://github.com/chef-cookbooks/iis/issues/217)

## v4.1.2 (2015-10-21)

- Bug fixes for application pool provider and site provider
- Added the ability to detect the IIS Version, allowing for some properties to only exist for specific IIS versions
- Fixed issue with Win32 being required on linux
- Added support for mimeTypes and defaultDocuments on iis_sites
- Added iis config set and clear abilities

## v4.1.1 (2015-05-07)

- Detects changes in the physical path of apps.
- Adds support for gMSA identity.
- Performing add on a site will now reconfigure it if necessary.
- Lock and unlock commands on configuration sections now use -commit:apphost.
- Fix issue where popeline_mode was ignored during configuration of a pool.

## v4.1.0 (2015-03-04)

- Removed iis_pool attribute 'set_profile_environment' incompatible with < IIS-8.
- Added pester test framework.
- Condensed and fixed change-log to show public releases only.
- Fixed bug where bindings were being overwritten by :config.
- Code-cleanup and cosmetic fixes.

## v4.0.0 (2015-02-12)

- [#91](https://github.com/chef-cookbooks/iis/pull/91) - bulk addition of new features

  - Virtual Directory Support (allows virtual directories to be added to both websites and to webapplications under sites).
  - section unlock and lock support (this is used to allow for the web.config of a site to define the authentication methods).
  - fixed issue with :add on pool provider not running all config (this was a known issue and is now resolved).
  - fixed issue with :config on all providers causing application pool recycles (every chef-client run).
  - moved to better method for XML checking of previous settings to detect changes (changed all check to use xml searching with appcmd instead of the previous method [none]).

- Improved pool resource with many more apppool properties that can be set.
- Fixed bug with default attribute inheritance.
- New recipe to enable ASP.NET 4.5.
- Skeleton serverspec+test-kitchen framework.
- Added Berksfile, Gemfile and .kitchen.yml to assist developers.
- Fixed issue [#107] function is_new_or_empty was returning reverse results.
- Removed dependency on "chef-client", ">= 3.7.0".
- Changed all files to UTF-8 file format.
- Fixed issue with iis_pool not putting ApplicationPoolIdentity and username/password.
- [#98] Fixed issues with bindings.
- added backwards compatibility for chef-client < 12.x.x Chef::Util::PathHelper.

## v2.1.6 (2014-11-12)

- [#78] Adds new_resource.updated_by_last_action calls

## v2.1.5 (2014-09-15)

- [#68] Add win_friendly_path to all appcmd.exe /physicalPath arguments

## v2.1.4 (2014-09-13)

- [#72] Adds chefspec matchers
- [#57] Fixes site_id not being updated on a :config action

## v2.1.2 (2014-04-23)

- [COOK-4559] Remove invalid UTF-8 characters

## v2.1.0 (2014-03-25)

[COOK-4426] - feature order correction for proper installation [COOK-4428] - Add IIS FTP Feature Installation

## v2.0.4 (2014-03-18)

- [COOK-4420] Corrected incorrect feature names for mod_security

## v2.0.2 (2014-02-25)

- [COOK-4108] - Add documentation for the 'bindings' attribute in 'iis_site' LWRP

## v2.0.0 (2014-01-03)

Major version bump

## v1.6.6

Adding extra windows platform checks to helper library

## v1.6.4

### Bug

- **[COOK-4138](https://tickets.chef.io/browse/COOK-4138)** - iis cookbook won't load on non-Windows platforms

## v1.6.2

### Improvement

- **[COOK-3634](https://tickets.chef.io/browse/COOK-3634)** - provide ability to set app pool managedRuntimeVersion to "No Managed Code"

## v1.6.0

### Improvement

- **[COOK-3922](https://tickets.chef.io/browse/COOK-3922)** - refactor IIS cookbook to not require WebPI

## v1.5.6

### Improvement

- **[COOK-3770](https://tickets.chef.io/browse/COOK-3770)** - Add Enabled Protocols to IIS App Recipe

## v1.5.4

### New Feature

- **[COOK-3675](https://tickets.chef.io/browse/COOK-3675)** - Add recipe for CGI module

## v1.5.2

### Bug

- **[COOK-3232](https://tickets.chef.io/browse/COOK-3232)** - Allow `iis_app` resource `:config` action with a virtual path

## v1.5.0

### Improvement

- [COOK-2370]: add MVC2, escape `application_pool` and add options for
- recycling
- [COOK-2694]: update iis documentation to show that Windows 2012 and
- Windows 8 are supported

### Bug

- [COOK-2325]: `load_current_resource` does not load state of pool
- correctly, always sets running to false
- [COOK-2526]: Installing IIS after .NET framework will leave
- installation in non-working state
- [COOK-2596]: iis cookbook fails with indecipherable error if EULA
- not accepted

## v1.4.0

- [COOK-2181] -Adding full module support to iis cookbook

## v1.3.6

- [COOK-2084] - Add support for additional options during site creation
- [COOK-2152] - Add recipe for IIS6 metabase compatibility

## v1.3.4

- [COOK-2050] - IIS cookbook does not have returns resource defined

## v1.3.2

- [COOK-1251] - Fix LWRP "NotImplementedError"

## v1.3.0

- [COOK-1301] - Add a recycle action to the iis_pool resource
- [COOK-1665] - app pool identity and new node[iis][component] attribute
- [COOK-1666] - Recipe to remove default site and app pool
- [COOK-1858] - Recipe misspelled

## v1.2.0

- [COOK-1061] - `iis_site` doesn't allow setting the pool
- [COOK-1078] - handle advanced bindings
- [COOK-1283] - typo on pool
- [COOK-1284] - install iis application initialization
- [COOK-1285] - allow multiple host_header, port and protocol
- [COOK-1286] - allow directly setting which app pool on site creation
- [COOK-1449] - iis pool regex returns true if similar site exists
- [COOK-1647] - mod_ApplicationInitialization isn't RC

## v1.1.0

- [COOK-1012] - support adding apps
- [COOK-1028] - support for config command
- [COOK-1041] - fix removal in app pools
- [COOK-835] - add app pool management
- [COOK-950] - documentation correction for version of IIS/OS

## v1.0.2

- Ruby 1.9 compat fixes
- ensure carriage returns are removed before applying regex

## v1.0.0

- [COOK-718] initial release

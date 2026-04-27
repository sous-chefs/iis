# IIS Cookbook Limitations

Research verified on April 27, 2026 against current Microsoft Learn documentation.

## Product scope

This cookbook manages Microsoft Internet Information Services (IIS), which is a Windows
component rather than a cross-platform web server package.

## Supported platforms and architecture

- IIS remains Windows-only. Microsoft documents IIS 10.0 as applying to Windows Server 2016,
  2019, 2022, and 2025, plus Windows 10 and Windows 11.
- This cookbook should stay focused on Windows Server use cases. The cookbook metadata already
  limits support to `windows`, and the migration should not add Linux coverage.
- For currently supported Windows Server releases, Microsoft requires a 64-bit processor with
  x64 instruction set support. In practice, this cookbook should be treated as an x64 Windows
  Server cookbook.

## Installation model

- IIS and its components are exposed by Windows as optional features / server roles.
- Feature enablement is done through Windows-native tooling such as DISM, PowerShell
  `Get-WindowsFeature` / `Install-WindowsFeature`, or the Windows Optional Feature UI.
- There is no apt/dnf/yum/homebrew style installation path to support in this cookbook.
- Optional IIS features can be absent until explicitly enabled, so module-oriented behavior
  must remain explicit in resource properties or test cookbook usage.

## Lifecycle constraints

- Microsoft lifecycle data shows IIS follows the Windows lifecycle because it is an operating
  system component.
- Older IIS releases tied to Windows Server 2012 / 2012 R2 and earlier are out of support, so
  the migration should not introduce suites or docs that depend on those platforms.

## Migration implications

- Keep Windows-only support.
- Prefer `iis_install` plus explicit `additional_components` over attribute-driven defaults.
- Model module enablement and default-site removal in the test cookbook with resources, not
  root recipes.

## Sources

- [Tuning IIS 10.0](https://learn.microsoft.com/en-us/windows-server/administration/performance-tuning/role/web-server/tuning-iis-10)
- [Internet Information Services (IIS) lifecycle](https://learn.microsoft.com/en-us/lifecycle/products/internet-information-services-iis)
- [Installing IIS Components](https://learn.microsoft.com/en-us/iis-administration/api/installing-features)
- [Hardware requirements for Windows Server](https://learn.microsoft.com/en-us/windows-server/get-started/hardware-requirements)

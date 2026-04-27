#
# Cookbook:: test
# Recipe:: site_powershell
#

iis_install 'install IIS FTP components with PowerShell features' do
  additional_components %w(IIS-FTPServer IIS-FTPSvc IIS-FTPExtensibility)
  install_method :windows_feature_powershell
  start_iis true
end

include_recipe 'test::site_common'

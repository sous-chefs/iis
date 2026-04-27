#
# Cookbook:: test
# Recipe:: base_install_powershell
#

iis_install 'install IIS with PowerShell features' do
  install_method :windows_feature_powershell
  start_iis true
end

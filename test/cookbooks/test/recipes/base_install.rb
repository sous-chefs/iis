#
# Cookbook:: test
# Recipe:: base_install
#

iis_install 'install IIS' do
  start_iis true
end

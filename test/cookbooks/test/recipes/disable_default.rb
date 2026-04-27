#
# Cookbook:: test
# Recipe:: disable_default
#

include_recipe 'test::base_install'

iis_site 'Default Web Site' do
  action [:stop, :delete]
end

iis_pool 'DefaultAppPool' do
  action [:stop, :delete]
end

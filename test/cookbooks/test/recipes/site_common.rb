#
# Cookbook:: test
# Recipe:: site_common
#

docroot = IISCookbook::Constants.iis_docroot

directory "#{docroot}\\site_test" do
  recursive true
end

directory "#{docroot}\\site_test2" do
  recursive true
end

directory "#{docroot}\\ftp_site_test" do
  recursive true
end

iis_site 'add/start to_be_deleted' do
  site_name 'to_be_deleted'
  application_pool 'DefaultAppPool'
  path "#{docroot}\\site_test"
  host_header 'localhost'
  port 8081
  action [:add, :start]
end

iis_site 'test' do
  application_pool 'DefaultAppPool'
  path "#{docroot}\\site_test"
  host_header 'localhost'
  action [:add, :start]
end

iis_site 'restart to_be_deleted' do
  site_name 'to_be_deleted'
  action :restart
end

iis_site 'test2' do
  application_pool 'DefaultAppPool'
  path "#{docroot}\\site_test2"
  host_header 'localhost'
  port 8080
  action [:add, :start]
end

iis_site 'stop/delete to_be_deleted' do
  site_name 'to_be_deleted'
  action [:stop, :delete]
end

iis_site 'myftpsite' do
  path "#{docroot}\\ftp_site_test"
  application_pool 'DefaultAppPool'
  bindings 'ftp/*:21:*'
  action [:add, :config]
end

directory "#{docroot}\\mytest" do
  action :create
end

iis_pool 'Test AppPool' do
  action [:add, :start]
end

iis_site 'add/start MyTest' do
  site_name 'MyTest'
  protocol :http
  port 8090
  path "#{docroot}\\mytest"
  action [:add, :start]
end

iis_app 'MyTest' do
  path '/testpool'
  application_pool 'Test AppPool'
  physical_path "#{docroot}\\mytest"
  enabled_protocols 'http'
  action :add
end

iis_site 'config MyTest' do
  site_name 'MyTest'
  protocol :http
  port 8090
  path "#{docroot}\\mytest"
  action :config
end

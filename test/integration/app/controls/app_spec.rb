# encoding: utf-8
# copyright: 2017, Chef Software, Inc.
# license: All rights reserved

title 'iis_app section'

describe service('W3SVC') do
  it { should be_installed }
  it { should be_running }
  its ('startmode') { should eq 'Auto' }
end

describe iis_site('Default Web Site') do
  it { should exist }
  it { should be_running }
  it { should have_app_pool('DefaultAppPool') }
end

describe iis_app('/v1_1', 'Default Web Site') do
  it { should exist }
  it { should have_application_pool('DefaultAppPool') }
  it { should have_physical_path('C:\\inetpub\\wwwroot\\v1_1') }
  it { should have_protocol('http') }
end

# encoding: utf-8
# copyright: 2017, Chef Software, Inc.
# license: All rights reserved

title 'iis_app section'

describe service('W3SVC') do
  it { should be_installed }
  it { should be_running }
  its ('startmode') { should eq 'Auto' }
end

describe iis_pool('myAppPool_v1_1') do
  it { should exist }
  it { should_not be_running }
  its('managed_runtime_version') { should eq 'v2.0' }
  it { should have_name('myAppPool_v1_1') }
  it { should have_queue_length(1000) }
end

describe iis_pool('testapppool') do
  it { should exist }
  it { should be_running }
  its('managed_runtime_version') { should eq 'v4.0' }
  its('managed_pipeline_mode') { should eq 'Integrated' }
  it { should have_name('testapppool') }
  its('start_mode') { should eq 'OnDemand' }
  its('identity_type') { should eq 'SpecificUser' }
  its('periodic_restart_schedule') { should eq ['06:00:00', '14:00:00', '17:00:00'] }
  its('username') { should include('\\vagrant') }
  its('password') { should eq 'vagrant' }
end

describe iis_pool('test_start') do
  it { should exist }
  it { should be_running }
  its('managed_pipeline_mode') { should eq 'Classic' }
  it { should have_name('test_start') }
end

describe iis_pool('My App Pool') do
  it { should exist }
  it { should be_running }
  it { should be_enable_32bit_app_on_win64 }
  its('managed_runtime_version') { should eq 'v4.0.30319' }
  its('managed_pipeline_mode') { should eq 'Integrated' }
  it { should have_name('My App Pool') }
end

describe iis_pool('test_identity_type') do
  it { should exist }
  it { should be_running }
  its('identity_type') { should eq 'NetworkService' }
end

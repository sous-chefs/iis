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
  it { should be_running }
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
  its('username') { should contain '\\vagrant' }
  its('password') { should eq 'vagrant' }
end

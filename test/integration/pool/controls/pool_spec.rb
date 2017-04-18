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

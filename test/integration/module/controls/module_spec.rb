# encoding: utf-8
# copyright: 2017, Chef Software, Inc.
# license: All rights reserved

title 'iis_module section'

describe service('W3SVC') do
  it { should be_installed }
  it { should be_running }
  its ('startmode') { should eq 'Auto' }
end

describe iis_module('example module', 'Default Web Site/v1_1') do
  it { should exist }
  it { should have_name('example module') }
  it { should have_pre_condition('managedHandler') }
  it { should have_type('System.Web.Handlers.ScriptModule, System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35') }
end

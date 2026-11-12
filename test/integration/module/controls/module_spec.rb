# frozen_string_literal: true

# copyright: 2017, Chef Software, Inc.
# license: All rights reserved

title 'iis_module section'

control 'iis-module-01' do
  impact 1.0
  title 'Verify IIS module configuration'

  describe service('W3SVC') do
    it { should be_installed }
    it { should be_running }
    its('startmode') { should eq 'Auto' }
  end

  describe iis_module('example module', 'Default Web Site/v1_1') do
    it { should exist }
    it { should have_name('example module') }
    it { should have_pre_condition('managedHandler') }
    it { should have_type('System.Web.Handlers.ScriptModule, System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35') }
  end

  describe iis_module('F5XFFHttpModule-x64') do
    it { should exist }
    it { should have_name('F5XFFHttpModule-x64') }
    it { should have_pre_condition('bitness64') }
  end

  describe iis_module('F5XFFHttpModule-x86') do
    it { should exist }
    it { should have_name('F5XFFHttpModule-x86') }
    it { should have_pre_condition('bitness32') }
  end
end

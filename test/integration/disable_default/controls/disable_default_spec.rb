# frozen_string_literal: true

# copyright: 2026, Sous Chefs
# license: Apache-2.0

control 'iis-disable-default-01' do
  impact 1.0
  title 'Verify IIS disable default configuration'

  describe service('W3SVC') do
    it { should be_installed }
    it { should be_running }
  end

  describe iis_site('Default Web Site') do
    it { should_not exist }
    it { should_not be_running }
  end

  describe powershell("Import-Module WebAdministration; Test-Path 'IIS:\\AppPools\\DefaultAppPool'") do
    its('stdout.strip') { should eq 'False' }
  end
end

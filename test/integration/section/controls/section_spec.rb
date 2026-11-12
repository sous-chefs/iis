# frozen_string_literal: true

# copyright: 2017, Chef Software, Inc.
# license: All rights reserved

title 'iis_section section'

control 'iis-section-01' do
  impact 1.0
  title 'Verify IIS section configuration'

  describe service('W3SVC') do
    it { should be_installed }
    it { should be_running }
    its('startmode') { should eq 'Auto' }
  end

  describe iis_section('system.webServer/staticContent', 'Default Web Site') do
    it { should exist }
    it { should have_override_mode('Allow') }
    it { should have_override_mode_effective('Allow') }
  end
end

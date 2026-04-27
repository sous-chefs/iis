# copyright: 2026, Sous Chefs
# license: Apache-2.0

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

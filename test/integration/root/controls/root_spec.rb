# copyright: 2017, Chef Software, Inc.
# license: All rights reserved

title 'iis_app section'

describe service('W3SVC') do
  it { should be_installed }
  it { should be_running }
  its('startmode') { should eq 'Auto' }
end

# This is not working and needs more investigation
# describe iis_root do
#   its('default_documents') { should eq ['test.html', 'Default.htm', 'Default.asp', 'index.htm', 'index.html', 'iisstart.htm', 'default.aspx'] }
# end

control 'document tests' do
  title 'Check IIS default documents are set'

  describe powershell('Import-Module WebAdministration; Get-WebConfiguration -Filter /system.webServer/defaultDocument/files/add -PSPath MACHINE/WEBROOT/APPHOST | Select-Object value') do
    its('stdout') { should match /test\.html/ }
    its('stdout') { should_not match /not_there\.html/ }
  end
end

control 'mime tests' do
  title 'Check IIS mimes are set'

  describe powershell('Get-WebConfiguration -Filter system.webServer/staticContent/mimeMap -PSPath MACHINE/WEBROOT/APPHOST | Select-Object fileExtension, mimeType') do
    its('stdout') { should match %r{\.dmg\s+application/octet-stream} }
    its('stdout') { should_not match %r{\.rpm\s+audio/x-pn-realaudio-plugin} }
    its('stdout') { should_not match %r{\.msi\s+application/octet-stream} }
  end
end

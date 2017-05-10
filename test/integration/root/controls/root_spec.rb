# encoding: utf-8
# copyright: 2017, Chef Software, Inc.
# license: All rights reserved

title 'iis_app section'

describe service('W3SVC') do
  it { should be_installed }
  it { should be_running }
  its ('startmode') { should eq 'Auto' }
end

describe iis_root do
  it { should have_document('test.html') }
  it { should_not have_document('not_there.html') }
  its('default_documents') { should eq ['test.html', 'Default.htm', 'Default.asp', 'index.htm', 'index.html', 'iisstart.htm', 'default.aspx'] }
  it { should have_mime("fileExtension='.323',mimeType='text/h323'") }
  it { should have_mime("fileExtension='.dmg',mimeType='application/octet-stream'") }
  it { should_not have_mime("fileExtension='.rpm',mimeType='audio/x-pn-realaudio-plugin'") }
  it { should_not have_mime("fileExtension='.msi',mimeType='application/octet-stream'") }
end

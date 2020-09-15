# encoding: utf-8
# copyright: 2018, Chef Software, Inc.
# license: All rights reserved

control 'config_property' do
  title 'Check IIS properties are set'

  describe powershell("(Get-WebConfigurationProperty -PSPath \"MACHINE/WEBROOT/APPHOST\" \
                      -filter \"system.applicationHost/sites/siteDefaults/logfile\" \
                      -Name \"directory\").value") do
    its('stdout') { should eq "D:\\logs\r\n" }
  end

  describe powershell("(Get-WebConfigurationProperty -PSPath \"MACHINE/WEBROOT/APPHOST\" \
                      -filter \"system.webServer/httpProtocol/customHeaders/add[@name='X-Xss-Protection']\" \
                      -Name \"value\").value") do
    its('stdout') { should eq "1; mode=block\r\n" }
  end

  describe powershell("(Get-WebConfigurationProperty -PSPath \"MACHINE/WEBROOT/APPHOST\" \
                      -Location \"Default Web site\" \
                      -filter \"system.webServer/aspNetCore/environmentVariables/environmentVariable[@name='ASPNETCORE_ENVIRONMENT']\" \
                      -Name \"value\").value") do
    its('stdout') { should eq "Test\r\n" }
  end
end

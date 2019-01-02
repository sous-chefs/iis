control 'Manager Permissions' do
  title 'Check permissions to access the manager has been correctly granted'

  describe powershell('[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Management") | Out-Null
  $current = [Microsoft.Web.Management.Server.ManagementAuthorization]::GetAuthorizedUsers("Default Web Site", $false, 0, 1000)
  ($current | ? { $_.ConfigurationPath -eq "/Default Web Site" } | Select-Object Name).Name') do
    its('strip') { should eq 'BUILTIN\\Users' }
  end
end

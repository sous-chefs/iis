describe 'iis::default'  {
  It "Checks for Web Server Role" {
    (Get-WindowsFeature -name Web-Server).Installed | Should Be $true
  }
}

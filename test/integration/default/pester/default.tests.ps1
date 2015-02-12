#
# Author:: Matt Stratton (<mattstratton@chef.io>)
#
# Copyright 2015, Chef, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

describe 'iis::default'  {
    It "Should have the Web Server Role" { 
      (Get-WindowsFeature -name Web-Server).Installed | Should Be $true # Probably not the right service name but it's okay for now.
    }

    It "Should have World Wide Web Publishing Service running" {
      (Get-Service -name 'W3SVC').status | Should Be 'Running'
      (Get-WmiObject win32_service | Where {$_.Name -eq "W3SVC"}).StartMode | Should Be "Auto"
    }

    It "Should have a default website" {
      Get-Website -Name "Default Web Site" | Should be $true
      (Get-Website -Name "Default Web Site").State | Should be "Started"
    }
    # We need to figure out a way to enssure that the app pool is bound to the site, etc, but this is a start
    It "Should have a default app pool" {
     Get-WebAppPoolState -Name "DefaultAppPool" | Should be $true
     (Get-WebAppPoolState -Name "DefaultAppPool").value | Should be "Started"
    }
}

#
# Copyright:: 2017, Chef Software, Inc.
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

describe service('W3SVC') do
  it { should be_installed }
  it { should be_running }
  its ('startmode') { should eq 'Auto' }
end

# Unless we are on a 'polluted' machine, the default website should
# be present if the IIS Role was freshly installed.  All our vagrant
# configurations install with the system drive at C:\
describe iis_site('test') do
  it { should exist }
  it { should be_running }
  it { should have_app_pool('DefaultAppPool') }
end

describe iis_site('test2') do
  it { should exist }
  it { should be_running }
  it { should have_app_pool('DefaultAppPool') }
  its('bindings') { should eq ['http *:8080:localhost'] }
end

describe iis_site('to_be_deleted') do
  it { should_not exist }
  it { should_not be_running }
end

describe iis_site('myftpsite') do
  it { should exist }
  it { should be_running }
  its('bindings') { should eq ['ftp *:21:*'] }
end

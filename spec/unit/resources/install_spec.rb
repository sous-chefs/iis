#
# Cookbook:: iis
# Spec:: install
#
# Copyright:: 2015-2021, Chef Software, Inc.
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

require 'ostruct'
require 'spec_helper'

describe 'iis_install' do
  step_into :iis_install
  context 'When no additional iis components provided, on an unspecified platform' do
    recipe do
      iis_install 'Just iis'
    end

    it 'installs windows feature IIS' do
      expect(chef_run).to install_windows_feature('Install IIS and additional components')
        .with(feature_name: ['IIS-WebServerRole'])
        .with(install_method: :windows_feature_dism)
    end
  end

  context 'When install_mode is powershell, on an unspecified platform' do
    shell_out = OpenStruct.new
    shell_out.strerr = ''
    shell_out.stdout = 'WebServer'
    stubs_for_provider('iis_install[Just iis powershell]') do |provider|
      allow(provider).to receive_shell_out().and_return(shell_out)
    end
    recipe do
      iis_install 'Just iis powershell' do
        install_method :windows_feature_powershell
      end
    end

    it 'installs windows feature IIS' do
      expect(chef_run).to install_windows_feature('Install IIS and additional components')
        .with(feature_name: ['WebServer'])
        .with(install_method: :windows_feature_powershell)
    end
  end

  context 'When install_mode is powershell as a string, on an unspecified platform' do
    shell_out = OpenStruct.new
    shell_out.strerr = ''
    shell_out.stdout = 'WebServer'
    stubs_for_provider('iis_install[Just iis powershell]') do |provider|
      allow(provider).to receive_shell_out().and_return(shell_out)
    end
    recipe do
      iis_install 'Just iis powershell' do
        install_method 'windows_feature_powershell'
      end
    end

    it 'installs windows feature IIS' do
      expect(chef_run).to install_windows_feature('Install IIS and additional components')
        .with(feature_name: ['WebServer'])
        .with(install_method: :windows_feature_powershell)
    end
  end

  context 'When start_iis is true' do
    recipe do
      iis_install 'Just iis' do
        start_iis true
      end
    end

    it 'enables iis service with name W3WVC' do
      expect(chef_run).to enable_service('iis').with(service_name: 'W3SVC')
    end

    it 'starts iis service with name W3WVC' do
      expect(chef_run).to start_service('iis').with(service_name: 'W3SVC')
    end
  end

  context 'When single additional component specified, on an unspecified platform' do
    recipe do
      iis_install 'IIs and Foobar' do
        additional_components 'foobar'
      end
    end

    it 'installs iis and additional component' do
      expect(chef_run).to install_windows_feature('Install IIS and additional components')
        .with(feature_name: %w(IIS-WebServerRole foobar))
    end
  end

  context 'When multiple additional components specified, on an unspecified platform' do
    recipe do
      iis_install 'IIs and Foobar' do
        additional_components %w(foo bar)
      end
    end

    it 'installs iis and additional component' do
      expect(chef_run).to install_windows_feature('Install IIS and additional components')
        .with(feature_name: %w(IIS-WebServerRole foo bar))
    end
  end

  context 'When source provided, on an unspecified platform' do
    recipe do
      iis_install 'just iis' do
        source 'somesource'
      end
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'installs features with source' do
      expect(chef_run).to install_windows_feature('Install IIS and additional components')
        .with(source: 'somesource')
    end
  end
end

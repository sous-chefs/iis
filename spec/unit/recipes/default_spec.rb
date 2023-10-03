#
# Cookbook:: iis
# Spec:: default
#
# Copyright:: 2015-2019, Chef Software, Inc.
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

require 'spec_helper'

describe 'iis::default' do
  context 'when iis components provided, on an unspecified platform' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.override['iis']['components'] = ['foobar']
      end.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'installs windows feature foobar' do
      expect(chef_run).to install_iis_install('install IIS').with(additional_components: ['foobar'])
    end
  end

  context 'When all attributes are default, on an unspecified platform' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end

  [:windows_feature_dism, :windows_feature_powershell, :windows_feature_servermanagercmd].each do |method|
    context "When iis windows feature install method is provided as #{method}, on a unspecified platform" do
      let(:chef_run) do
        ChefSpec::SoloRunner.new do |node|
          node.override['iis']['windows_feature_install_method'] = method
        end.converge(described_recipe)
      end

      it "installs windows features using #{method}" do
        expect(chef_run).to install_iis_install('install IIS').with(install_method: method)
      end
    end
  end

  context 'When source provided, on an unspecified platform' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.override['iis']['source'] = 'somesource'
      end.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'installs features with source' do
      chef_run.node.override['iis']['source'] = 'somesource'
      chef_run.converge(described_recipe)
      expect(chef_run).to install_iis_install('install IIS').with(source: 'somesource')
    end
  end
end

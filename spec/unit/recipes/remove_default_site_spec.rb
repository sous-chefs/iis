#
# Cookbook:: iis
# Spec:: default
#
# Copyright:: 2015-2016, Chef Software, Inc.
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

describe 'iis::remove_default_site' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

    it 'stops default site' do
      expect(chef_run).to stop_iis_site('Default Web Site')
    end

    it 'deletes default site' do
      expect(chef_run).to delete_iis_site('Default Web Site')
    end

    it 'stops default app pool' do
      expect(chef_run).to stop_iis_pool('DefaultAppPool')
    end

    it 'deletes default app pool ' do
      expect(chef_run).to delete_iis_pool('DefaultAppPool')
    end
  end
end

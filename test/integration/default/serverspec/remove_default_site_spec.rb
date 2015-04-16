#
# Author:: Kartik Cating-Subramanian (<ksubramanian@chef.io>)
#
# Copyright 2015, Chef Software, Inc.
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

require 'spec_helper'

describe 'iis::remove_default_site' do
  describe iis_website('Default Website') do
    it { should_not exist }
  end

  describe iis_app_pool('Default App Pool') do
    it { should_not exist }
  end
end

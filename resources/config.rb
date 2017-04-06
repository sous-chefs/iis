#
# Cookbook:: iis
# Resource:: config
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

include Opscode::IIS::Helper
include Opscode::IIS::Processors

property    :cfg_cmd,   String,             name_attribute: true
property    :returns,   [Integer, Array],   default: 0

default_action :set

action :set do
  config
end

action :clear do
  config(:clear)
end

action_class.class_eval do
  def config(action = :set)
    converge_by "Executing IIS Config #{action}" do
      cmd = "#{appcmd(node)} #{action} config #{new_resource.cfg_cmd}"
      Chef::Log.debug(cmd)
      shell_out!(cmd, returns: new_resource.returns)
    end
  end
end

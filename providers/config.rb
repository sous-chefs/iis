#
# Author:: Kendrick Martin (kendrick.martin@webtrends.com)
# Contributor:: David Dvorak (david.dvorak@webtrends.com)
# Cookbook Name:: iis
# Resource:: config
#
# Copyright:: 2011, Webtrends Inc.
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

require 'chef/mixin/shell_out'

include Chef::Mixin::ShellOut
include Opscode::IIS::Helper
include Opscode::IIS::Processors

# :config deprecated, use :set instead
action :config do
  Chef::Log.warn <<-eos
    Use of action `:config` in resource `iis_config` is now deprecated and will be removed in a future release (v4.2.0).
    `:set` should be used instead.
    eos
  new_resource.updated_by_last_action(true) if config
end

action :set do
  new_resource.updated_by_last_action(true) if config
end

action :clear do
  new_resource.updated_by_last_action(true) if config(:clear)
end

def config(action = :set)
  cmd = "#{appcmd(node)} #{action} config #{new_resource.cfg_cmd}"
  Chef::Log.debug(cmd)
  shell_out!(cmd, returns: new_resource.returns)
  Chef::Log.info('IIS Config command run')
  new_resource.updated_by_last_action(true)
end

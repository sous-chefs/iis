#
# Cookbook:: iis
# Resource:: module
#
# Copyright:: 2012-2017, Chef Software, Inc.
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

property  :module_name,   String,             name_attribute: true
property  :type,          [String, nil],      default: nil
property  :add,           [true, false, nil], default: nil
property  :image,         [String, nil],      default: nil
property  :precondition,  [String, nil],      default: nil
property  :application,   [String, nil],      default: nil
property  :exists,        [true, false],      desired_state: true

load_current_value do |desired|
  module_name desired.module_name
  cmd = if desired.application
          shell_out("#{appcmd(node)} list module /module.name:\"#{desired.module_name}\" /app.name:\"#{desired.application}\"")
        else
          shell_out("#{appcmd(node)} list module /module.name:\"#{desired.module_name}\"")
        end

  # 'MODULE "Module Name" ( type:module.type, preCondition:condition )'
  # 'MODULE "Module Name" ( native, preCondition:condition )'

  Chef::Log.debug("#{desired} list module command output: #{cmd.stdout}")
  exists !cmd.stdout.empty?
end

# appcmd syntax for adding modules
# appcmd add module /name:string /type:string /preCondition:string
action :add do
  if !current_resource.exists
    converge_by("add IIS module #{new_resource.module_name}") do
      cmd = "#{appcmd(node)} add module /module.name:\"#{new_resource.module_name}\""

      if new_resource.application
        cmd << " /app.name:\"#{new_resource.application}\""
      end

      cmd << " /type:\"#{new_resource.type}\"" if new_resource.type

      if new_resource.precondition
        cmd << " /preCondition:\"#{new_resource.precondition}\""
      end

      shell_out!(cmd, returns: [0, 42])
      Chef::Log.info("#{new_resource} added module '#{new_resource.module_name}'")
    end
  else
    Chef::Log.debug("#{new_resource} module already exists - nothing to do")
  end
end

action :delete do
  if current_resource.exists
    converge_by("delete IIS module #{new_resource.module_name}") do
      cmd = "#{appcmd(node)} delete module /module.name:\"#{new_resource.module_name}\""
      if new_resource.application
        cmd << " /app.name:\"#{new_resource.application}\""
      end

      shell_out!(cmd, returns: [0, 42])
    end

    Chef::Log.info("#{new_resource} deleted")
  else
    Chef::Log.debug("#{new_resource} module does not exist - nothing to do")
  end
end

# appcmd syntax for installing native modules
# appcmd install module /name:string /add:string(true|false) /image:string
action :install do
  if !current_resource.exists
    converge_by("install IIS module #{new_resource.module_name}") do
      cmd = "#{appcmd(node)} install module /name:\"#{new_resource.module_name}\""
      cmd << " /add:\"#{new_resource.add}\"" unless new_resource.add.nil?
      cmd << " /image:\"#{new_resource.image}\"" if new_resource.image
      cmd << " /preCondition:\"#{new_resource.precondition}\"" if new_resource.precondition

      shell_out!(cmd, returns: [0, 42])
      Chef::Log.info("#{new_resource} installed module '#{new_resource.module_name}'")
    end
  else
    Chef::Log.debug("#{new_resource} module already exists - nothing to do")
  end
end

# appcmd syntax for uninstalling native modules
# appcmd uninstall module <name>
action :uninstall do
  if current_resource.exists
    converge_by("uninstall IIS module #{new_resource.module_name}") do
      cmd = "#{appcmd(node)} uninstall module \"#{new_resource.module_name}\""

      shell_out!(cmd, returns: [0, 42])
    end

    Chef::Log.info("#{new_resource} uninstalled module '#{new_resource.module_name}'")
  else
    Chef::Log.debug("#{new_resource} module does not exists - nothing to do")
  end
end

action_class do
  # Support whyrun
  def whyrun_supported?
    true
  end
end
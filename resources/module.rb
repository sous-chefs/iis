#
# Cookbook:: iis
# Resource:: module
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
include Opscode::IIS::SectionHelper

property :module_name, String, name_property: true
property :type, String
property :add, [true, false], default: false
property :image, String
property :precondition, String
property :application, String
property :previous_lock, String

default_action :add

load_current_value do |desired|
  module_name desired.module_name
  application desired.application if desired.application
  # Sanitize Image Path (file system path)
  desired.image = windows_cleanpath(desired.image) if desired.image
  cmd = "#{appcmd(node)} list module /module.name:\"#{desired.module_name}\""
  cmd << " /app.name:\"#{desired.application}\"" if desired.application

  cmd_result = shell_out cmd
  # 'MODULE "Module Name" ( type:module.type, preCondition:condition )'
  # 'MODULE "Module Name" ( native, preCondition:condition )'

  Chef::Log.debug("#{desired.name} list module command output: #{cmd_result.stdout}")
  unless cmd_result.stdout.empty?
    previous_lock get_current_lock(node, 'system.webServer/modules', desired.application)
    cmd = "#{appcmd(node)} list module /module.name:\"#{desired.module_name}\""
    cmd << " /app.name:\"#{desired.application}\"" if desired.application
    cmd << ' /config:* /xml'
    cmd_result = shell_out cmd
    if cmd_result.stderr.empty?
      xml = cmd_result.stdout
      doc = Document.new(xml)
      type value doc.root, 'MODULE/@type'
      precondition value doc.root, 'MODULE/@preCondition'
    end
  end
end

# appcmd syntax for adding modules
# appcmd add module /name:string /type:string /preCondition:string
action :add do
  if exists
    Chef::Log.debug("#{new_resource} module already exists - nothing to do")
  else
    converge_by("add IIS module #{new_resource.module_name}") do
      unlock(node, 'system.webServer/modules', new_resource.application)
      cmd = "#{appcmd(node)} add module /module.name:\"#{new_resource.module_name}\""
      cmd << " /app.name:\"#{new_resource.application}\"" if new_resource.application
      cmd << " /type:\"#{new_resource.type}\"" if new_resource.type
      cmd << " /preCondition:\"#{new_resource.precondition}\"" if new_resource.precondition

      shell_out!(cmd, returns: [0, 42])
      override_mode(node, current_resource.previous_lock, 'system.webServer/modules', new_resource.application)
    end
  end
end

action :delete do
  if exists
    converge_by("delete IIS module #{new_resource.module_name}") do
      unlock(node, 'system.webServer/modules', new_resource.application)
      cmd = "#{appcmd(node)} delete module /module.name:\"#{new_resource.module_name}\""
      cmd << " /app.name:\"#{new_resource.application}\"" if new_resource.application

      shell_out!(cmd, returns: [0, 42])
      override_mode(node, current_resource.previous_lock, 'system.webServer/modules', new_resource.application)
    end
  else
    Chef::Log.debug("#{new_resource} module does not exist - nothing to do")
  end
end

# appcmd syntax for installing native modules
# appcmd install module /name:string /add:string(true|false) /image:string
action :install do
  if exists
    Chef::Log.debug("#{new_resource} module already exists - nothing to do")
  else
    converge_by("install IIS module #{new_resource.module_name}") do
      unlock(node, 'system.webServer/modules', new_resource.application)
      cmd = "#{appcmd(node)} install module /name:\"#{new_resource.module_name}\""
      cmd << " /add:\"#{new_resource.add}\"" unless new_resource.add.nil?
      cmd << " /image:\"#{new_resource.image}\"" if new_resource.image
      cmd << " /preCondition:\"#{new_resource.precondition}\"" if new_resource.precondition

      shell_out!(cmd, returns: [0, 42])
      override_mode(node, current_resource.previous_lock, 'system.webServer/modules', new_resource.application)
    end
  end
end

# appcmd syntax for uninstalling native modules
# appcmd uninstall module <name>
action :uninstall do
  if exists
    converge_by("uninstall IIS module #{new_resource.module_name}") do
      unlock(node, 'system.webServer/modules', new_resource.application)
      cmd = "#{appcmd(node)} uninstall module \"#{new_resource.module_name}\""

      shell_out!(cmd, returns: [0, 42])
      override_mode(node, current_resource.previous_lock, 'system.webServer/modules', new_resource.application)
    end
  else
    Chef::Log.debug("#{new_resource} module does not exists - nothing to do")
  end
end

action_class.class_eval do
  def exists
    current_resource.type ? true : false
  end
end

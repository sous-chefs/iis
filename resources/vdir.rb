#
# Cookbook:: iis
# Resource:: vdir
#
# Copyright:: 2016-2017, Chef Software, Inc.
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

require 'rexml/document'

include REXML
include Opscode::IIS::Helper
include Opscode::IIS::Processors

property :application_name, String, name_property: true
property :path, String
property :physical_path, String
property :username, String
property :password, String
property :logon_method, [Symbol, String], default: :ClearText, equal_to: [:Interactive, :Batch, :Network, :ClearText], coerce: proc { |v| v.to_sym }
property :allow_sub_dir_config, [true, false], default: true

default_action :add

load_current_value do |desired|
  # Sanitize Application Name
  desired.application_name = application_cleanname(desired.application_name)
  # Sanitize Physical Path
  desired.physical_path = windows_cleanpath(desired.physical_path) if desired.physical_path
  application_name desired.application_name
  path desired.path
  cmd = shell_out("#{appcmd(node)} list vdir \"#{application_name.chomp('/') + path}\"")
  Chef::Log.debug("#{desired} list vdir command output: #{cmd.stdout}")

  if cmd.stderr.empty?
    # VDIR "Testfu Site/Content/Test"
    result = cmd.stdout.match(/^VDIR\s\"#{Regexp.escape(application_name.chomp('/') + path)}\"/)
    Chef::Log.debug("#{desired} current_resource match output: #{result}")
    unless result.nil?
      cmd = shell_out("#{appcmd(node)} list vdir \"#{application_name.chomp('/') + path}\" /config:* /xml")
      if cmd.stderr.empty?
        xml = cmd.stdout
        doc = Document.new(xml)
        physical_path windows_cleanpath(value(doc.root, 'VDIR/@physicalPath'))
        username value doc.root, 'VDIR/virtualDirectory/@userName'
        password value doc.root, 'VDIR/virtualDirectory/@password'
        logon_method value(doc.root, 'VDIR/virtualDirectory/@logonMethod').to_sym
        allow_sub_dir_config bool(value(doc.root, 'VDIR/virtualDirectory/@allowSubDirConfig'))
      end
    end
  else
    Chef::Log.warn "Failed to run iis_vdir action :load_current_resource, #{cmd.stderr}"
  end
end

action :add do
  if exists
    Chef::Log.debug("#{new_resource} virtual directory already exists - nothing to do")
  else
    converge_by "Created the VDIR - \"#{new_resource}\"" do
      cmd = "#{appcmd(node)} add vdir /app.name:\"#{vdir_identifier}\""
      cmd << " /path:\"#{new_resource.path}\""
      cmd << " /physicalPath:\"#{new_resource.physical_path}\""
      cmd << " /userName:\"#{new_resource.username}\"" if new_resource.username
      cmd << " /password:\"#{new_resource.password}\"" if new_resource.password
      cmd << " /logonMethod:#{new_resource.logon_method}" if new_resource.logon_method
      cmd << " /allowSubDirConfig:#{new_resource.allow_sub_dir_config}" if new_resource.allow_sub_dir_config
      cmd << ' /commit:\"MACHINE/WEBROOT/APPHOST\"'

      Chef::Log.debug(cmd)
      shell_out!(cmd, returns: [0, 42, 183])
    end
  end
end

action :config do
  if exists
    cmd = "#{appcmd(node)} set vdir \"#{application_identifier}\""
    converge_if_changed :physical_path do
      cmd << " /physicalPath:\"#{new_resource.physical_path}\""
    end

    converge_if_changed :username do
      cmd << " /userName:\"#{new_resource.username}\""
    end

    converge_if_changed :password do
      cmd << " /password:\"#{new_resource.password}\""
    end

    converge_if_changed :logon_method do
      cmd << " /logonMethod:#{new_resource.logon_method}"
    end

    converge_if_changed :allow_sub_dir_config do
      cmd << " /allowSubDirConfig:#{new_resource.allow_sub_dir_config}"
    end

    if cmd != "#{appcmd(node)} set vdir \"#{application_identifier}\""
      converge_by "Updated the VDIR - \"#{new_resource}\"" do
        Chef::Log.debug(cmd)
        shell_out!(cmd)
      end
    else
      Chef::Log.debug("#{new_resource} virtual directory - nothing changed")
    end
  end
end

action :delete do
  if exists
    converge_by "Deleted the VDIR - \"#{new_resource}\"" do
      Chef::Log.debug("#{appcmd(node)} delete vdir \"#{application_identifier}\"")
      shell_out!("#{appcmd(node)} delete vdir \"#{application_identifier}\"", returns: [0, 42])
    end
  else
    Chef::Log.debug("#{new_resource} virtual directory does not exist - nothing to do")
  end
end

action_class.class_eval do
  def exists
    current_resource.physical_path ? true : false
  end

  def application_identifier
    new_resource.path.start_with?('/') ? vdir_identifier.chomp('/') + new_resource.path : vdir_identifier + new_resource.path
  end

  def vdir_identifier
    new_resource.application_name.include?('/') ? new_resource.application_name : new_resource.application_name + '/'
  end
end

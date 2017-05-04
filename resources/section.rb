#
# Cookbook:: iis
# Resource:: section
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
include Opscode::IIS::SectionHelper
include Opscode::IIS::Processors

property :section, String, name_property: true
property :site, String
property :application_path, String
property :returns, [Integer, Array], default: 0
property :locked, String

default_action :unlock

load_current_value do |desired|
  section desired.section
  site desired.site
  application_path desired.application_path
  command_path = 'MACHINE/WEBROOT/APPHOST'
  command_path << "/#{site}" if site
  command_path << application_path.to_s if application_path
  cmd = "#{appcmd(node)} list config \"#{command_path}\""
  cmd << " -section:\"#{section}\" /commit:apphost /config:* /xml"
  Chef::Log.debug(cmd)
  cmd = shell_out(cmd)
  if cmd.stderr.empty?
    xml = cmd.stdout
    doc = Document.new(xml)
    locked value doc.root, 'CONFIG/@overrideMode'
  else
    Chef::Log.info(cmd.stderr)
  end
end

action :lock do
  if current_resource.locked != 'Deny'
    converge_by "Locking the section - \"#{new_resource}\"" do
      lock node, new_resource.section, "#{new_resource.site}#{new_resource.application_path}", new_resource.returns
    end
  else
    Chef::Log.debug("#{new_resource} already locked - nothing to do")
  end
end

action :unlock do
  if current_resource.locked != 'Allow'
    converge_by "Unlocking the section - \"#{new_resource}\"" do
      unlock node, new_resource.section, "#{new_resource.site}#{new_resource.application_path}", new_resource.returns
    end
  else
    Chef::Log.debug("#{new_resource} already unlocked - nothing to do")
  end
end

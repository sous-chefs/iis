#
# Cookbook:: iis
# Library:: section-helper
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

module Opscode
  module IIS
    # Contains functions that are used throughout this cookbook
    module SectionHelper
      require 'rexml/document'
      include REXML

      def lock(node, section, location = '', returns = [0])
        cmd_list_section node, :lock, section, location, returns
      end

      def unlock(node, section, location = '', returns = [0])
        cmd_list_section node, :unlock, section, location, returns
      end

      def override_mode(node, action, section, location = '', returns = [0])
        cmd_list_section(node, action, section, location, returns)
      end

      def get_current_lock(node, section, location = '')
        command_path = 'MACHINE/WEBROOT/APPHOST'
        command_path << "/#{location}" if location
        cmd = "#{appcmd(node)} list config \"#{command_path}}\""
        cmd << " -section:#{section} -commit:apphost /config:* /xml"
        result = shell_out cmd
        if result.stderr.empty?
          xml = result.stdout
          doc = Document.new xml
          value(doc.root, 'CONFIG/@overrideMode')
        else
          Chef::Log.info(result.stderr)
        end

        nil
      end

      def cmd_section(node, check, section, location, returns)
        cmd = "#{appcmd(node)} set config \"MACHINE/WEBROOT/APPHOST/#{location}\""
        cmd << " -section:\"#{section}\" -overrideMode:#{check}"
        cmd << ' -commit:apphost'
        Chef::Log.debug(cmd)
        shell_out!(cmd, returns: returns)

        return unless location
        cmd = "#{appcmd(node)} set config \"MACHINE/WEBROOT/APPHOST/#{location}\""
        cmd << " -section:\"#{section}\" -overrideMode:#{check}"
        Chef::Log.debug(cmd)
        shell_out!(cmd, returns: returns)
      end

      def cmd_list_section(node, action, section, location, returns)
        current_lock = get_current_lock(node, section, location)
        check = action if action == 'Inherit'
        check = (action == :lock ? 'Deny' : 'Allow') if action != 'Inherit'

        cmd_section node, check, section, location, returns unless current_lock == check
      end
    end
  end
end

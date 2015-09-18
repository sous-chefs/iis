#
# Cookbook Name:: iis
# Library:: helper
#
# Author:: Julian C. Dunn <jdunn@chef.io>
# Author:: Justin Schuhmann <jmschu02@gmail.com>
#
# Copyright 2013, Chef Software, Inc.
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
    module Helper
      @iis_version = nil

      if RUBY_PLATFORM =~ /mswin|mingw32|windows/
        require 'chef/win32/version'
        require 'win32/registry'
      end

      require 'rexml/document'
      require 'chef/mixin/shell_out'

      include Chef::Mixin::ShellOut
      include REXML
      include Windows::Helper

      def self.older_than_windows2008r2?
        if RUBY_PLATFORM =~ /mswin|mingw32|windows/
          win_version = Chef::ReservedNames::Win32::Version.new
          win_version.windows_server_2008? ||
            win_version.windows_vista? ||
            win_version.windows_server_2003_r2? ||
            win_version.windows_home_server? ||
            win_version.windows_server_2003? ||
            win_version.windows_xp? ||
            win_version.windows_2000?
        end
      end

      def self.older_than_windows2012?
        if RUBY_PLATFORM =~ /mswin|mingw32|windows/
          win_version = Chef::ReservedNames::Win32::Version.new
          win_version.windows_7? ||
            win_version.windows_server_2008_r2? ||
            win_version.windows_server_2008? ||
            win_version.windows_vista? ||
            win_version.windows_server_2003_r2? ||
            win_version.windows_home_server? ||
            win_version.windows_server_2003? ||
            win_version.windows_xp? ||
            win_version.windows_2000?
        end
      end

      def windows_cleanpath(path)
        if !defined?(Chef::Util::PathHelper.cleanpath).nil?
          path = Chef::Util::PathHelper.cleanpath(path)
        else
          path = win_friendly_path(path)
        end
        # Remove any trailing slashes to prevent them from accidentally escaping any quotes.
        path.chomp('/').chomp('\\')
      end

      def new_value?(document, xpath, value_to_check)
        XPath.first(document, xpath).to_s != value_to_check.to_s
      end

      def new_or_empty_value?(document, xpath, value_to_check)
        value_to_check.to_s != '' && new_value?(document, xpath, value_to_check)
      end

      def appcmd(node)
        @appcmd ||= begin
          "#{node['iis']['home']}\\appcmd.exe"
        end
      end

      def get_iis_version
        if @iis_version.nil?
          version_string = Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Microsoft\InetStp').read('VersionString')[1]
          version_string.slice! 'Version '
          @iis_version = version_string
        end
        @iis_version
      end

      def default_documents(default_document, default_documents_enabled, add = true, remove = true, specifier = '')
        cmd = shell_out get_default_documents_command specifier
        if cmd.stderr.empty?
          xml = cmd.stdout
          doc = Document.new xml

          is_new_default_documents_enabled = new_value?(doc.root, 'CONFIG/system.webServer-defaultDocument/@enabled', default_documents_enabled.to_s)
          current_default_documents = XPath.match(doc.root, 'CONFIG/system.webServer-defaultDocument/files/add/@value').map(&:value)
          cmd = set_default_documents_command specifier

          if is_new_default_documents_enabled
            cmd << " /enabled:#{default_documents_enabled}"
          end

          if add || remove
            default_document.each do |document|
              if !current_default_documents.include?(document) && add
                cmd << " /+files.[value='#{document}']"
              elsif current_default_documents.include?(document) && remove
                cmd << " /-files.[value='#{document}']"
              end
            end
          end

          if add && remove
            current_default_documents.each do |document|
              unless default_document.include? document
                cmd << " /-files.[value='#{document}']"
              end
            end
          end

          if (cmd != set_default_documents_command(specifier))
            shell_out! cmd
            Chef::Log.info('Default Documents updated')
            was_updated = true
          end
        end
      end

      def mime_maps(new_resource_mime_maps, add = true, remove = true, specifier = '')
        # handles mime maps
        cmd = shell_out get_mime_map_command specifier
        if cmd.stderr.empty?
          xml = cmd.stdout
          doc = Document.new xml
          current_mime_maps = XPath.match(doc.root, 'CONFIG/system.webServer-staticContent/mimeMap').map { |x| "fileExtension='#{x.attribute 'fileExtension'}',mimeType='#{x.attribute 'mimeType'}'" }

          cmd = set_mime_map_command specifier

          if add || remove
            new_resource_mime_maps.each do |mime_map|
              if !current_mime_maps.include? mime_map && add
                cmd << " /+\"[#{mime_map}]\""
              elsif current_mime_maps.include? mime_map && remove
                cmd << " /-\"[#{mime_map}]\""
              end
            end
          end

          if add && remove
            current_mime_maps.each do |mime_map|
              unless new_resource_mime_maps.include? mime_map
                cmd << " /-\"[#{mime_map}]\""
              end
            end
          end

          if (cmd != set_mime_map_command(specifier))
            shell_out! cmd
            Chef::Log.info('mime maps updated')
            was_updated = true
          end
        end
      end

      private

      def get_default_documents_command(specifier = '')
        "#{appcmd(node)} list config #{specifier} /section:defaultDocument /config:* /xml"
      end

      def set_default_documents_command(specifier = '')
        "#{appcmd(node)} set config #{specifier} /section:defaultDocument"
      end

      def get_mime_map_command(specifier = '')
        "#{appcmd(node)} list config #{specifier} /section:staticContent /config:* /xml"
      end

      def set_mime_map_command(specifier = '')
        "#{appcmd(node)} set config #{specifier} /section:staticContent"
      end
    end
  end
end

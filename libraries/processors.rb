#
# Cookbook:: iis
# Library:: helper
#
# Author:: Justin Schuhmann <jmschu02@gmail.com>
#
# Copyright:: 2013-2016, Chef Software, Inc.
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
    module Processors
      def default_documents(default_document, default_documents_enabled, add = true, remove = true, specifier = '')
        cmd = shell_out! get_default_documents_command specifier
        return unless cmd.stderr.empty?
        xml = cmd.stdout
        doc = REXML::Document.new xml

        is_new_default_documents_enabled = new_value?(doc.root, 'CONFIG/system.webServer-defaultDocument/@enabled', default_documents_enabled.to_s)
        current_default_documents = REXML::XPath.match(doc.root, 'CONFIG/system.webServer-defaultDocument/files/add/@value').map(&:value)
        cmd = default_documents_command specifier

        if is_new_default_documents_enabled
          cmd << " /enabled:#{default_documents_enabled}"
        end

        if add
          (default_document - current_default_documents).each do |document|
            cmd << " /+files.[value='#{document}']"
          end
        end
        if remove && !add
          (default_document - current_default_documents).each do |document|
            cmd << " /-files.[value='#{document}']"
          end
        end
        if remove && add
          (current_default_documents - default_document).each do |document|
            cmd << " /-files.[value='#{document}']"
          end
        end

        return unless cmd != default_documents_command(specifier)
        shell_out! cmd
        Chef::Log.info('Default Documents updated')
        @was_updated = true
      end

      def mime_maps(new_resource_mime_maps, add = true, remove = true, specifier = '')
        # handles mime maps
        cmd = shell_out get_mime_map_command specifier
        return unless cmd.stderr.empty?
        xml = cmd.stdout
        doc = REXML::Document.new xml
        current_mime_maps = REXML::XPath.match(doc.root, 'CONFIG/system.webServer-staticContent/mimeMap').map { |x| "fileExtension='#{x.attribute 'fileExtension'}',mimeType='#{x.attribute 'mimeType'}'" }
        cmd = mime_map_command specifier

        if add
          (new_resource_mime_maps - current_mime_maps).each do |mime_map|
            cmd << " /+\"[#{mime_map}]\""
          end
        end
        if remove && !add
          (new_resource_mime_maps - current_mime_maps).each do |mime_map|
            cmd << " /-\"[#{mime_map}]\""
          end
        end
        if remove && add
          (current_mime_maps - new_resource_mime_maps).each do |mime_map|
            cmd << " /-\"[#{mime_map}]\""
          end
        end

        return unless cmd != mime_map_command(specifier)
        shell_out! cmd
        Chef::Log.info('mime maps updated')
        @was_updated = true
      end

      private

      def get_default_documents_command(specifier = '')
        "#{appcmd(node)} list config #{specifier} /section:defaultDocument /config:* /xml"
      end

      def default_documents_command(specifier = '')
        "#{appcmd(node)} set config #{specifier} /section:defaultDocument"
      end

      def get_mime_map_command(specifier = '')
        "#{appcmd(node)} list config #{specifier} /section:staticContent /config:* /xml"
      end

      def mime_map_command(specifier = '')
        "#{appcmd(node)} set config #{specifier} /section:staticContent"
      end
    end
  end
end

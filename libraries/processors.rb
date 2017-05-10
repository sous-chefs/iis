#
# Cookbook:: iis
# Library:: processors
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
    module Processors
      def current_default_documents_config(specifier = '')
        cmd = shell_out! get_default_documents_command specifier
        return unless cmd.stderr.empty?
        xml = cmd.stdout
        doc = REXML::Document.new xml

        {
          default_documents_enabled: value(doc.root, 'CONFIG/system.webServer-defaultDocument/@enabled'),
          default_documents: REXML::XPath.match(doc.root, 'CONFIG/system.webServer-defaultDocument/files/add/@value').map(&:value),
        }
      end

      def current_mime_maps_config(specifier = '')
        # handles mime maps
        cmd = shell_out! get_mime_map_command specifier
        return unless cmd.stderr.empty?
        xml = cmd.stdout
        doc = REXML::Document.new xml

        REXML::XPath.match(doc.root, 'CONFIG/system.webServer-staticContent/mimeMap').map { |x| "fileExtension='#{x.attribute 'fileExtension'}',mimeType='#{x.attribute 'mimeType'}'" }
      end

      def set_default_documents_enabled(value, specifier = '')
        cmd = default_documents_command specifier
        cmd << " /enabled:#{value}"
        shell_out! cmd
      end

      def set_default_documents(desired_default_documents, current_default_documents, add = true, remove = true, specifier = '')
        cmd = default_documents_command specifier
        Chef::Log.warn("new #{desired_default_documents} --- old #{current_default_documents}")
        if add
          (desired_default_documents - current_default_documents).each do |document|
            cmd << " /+files.[value='#{document}']"
          end
        end
        if remove && !add
          (desired_default_documents - current_default_documents).each do |document|
            cmd << " /-files.[value='#{document}']"
          end
        end
        if remove && add
          (current_default_documents - desired_default_documents).each do |document|
            cmd << " /-files.[value='#{document}']"
          end
        end

        Chef::Log.warn("before cmd -- #{cmd}")

        return unless cmd != default_documents_command(specifier)
        Chef::Log.warn("after cmd -- #{cmd}")
        shell_out! cmd
      end

      def set_mime_maps(desired_mime_maps, current_mime_maps, add = true, remove = true, specifier = '')
        cmd = mime_map_command specifier

        if add
          (desired_mime_maps - current_mime_maps).each do |mime_map|
            cmd << " /+\"[#{mime_map}]\""
          end
        end
        if remove && !add
          (desired_mime_maps - current_mime_maps).each do |mime_map|
            cmd << " /-\"[#{mime_map}]\""
          end
        end
        if remove && add
          (current_mime_maps - desired_mime_maps).each do |mime_map|
            cmd << " /-\"[#{mime_map}]\""
          end
        end

        return unless cmd != mime_map_command(specifier)
        shell_out! cmd
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

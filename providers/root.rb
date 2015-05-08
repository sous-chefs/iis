#
# Author:: Justin Schuhmann (<jmschu02@gmail.com>)
# Cookbook Name:: iis
# Provider:: root
#
# Copyright:: Justin Schuhmann
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
require 'rexml/document'

include Chef::Mixin::ShellOut
include REXML
include Opscode::IIS::Helper

action :config do
	was_updated = false

	was_updated = default_documents || was_updated
	was_updated = mime_maps || was_updated

	if was_updated
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.debug("#{new_resource} - nothing to do")
	end
end

def load_current_resource
  @current_resource = Chef::Resource::IisRoot.new(new_resource.name)
  @current_resource.default_documents(new_resource.default_documents)
  @current_resource.default_documents_enabled(new_resource.default_documents_enabled)
  @current_resource.mime_maps(new_resource.mime_maps)
end

private
	def default_documents
		# handles default documents
	  cmd = shell_out "#{appcmd(node)} list config /section:defaultDocument /config:* /xml"
	  if cmd.stderr.empty?
	    xml = cmd.stdout
	    doc = Document.new xml
	    is_new_default_documents_enabled = new_value?(doc.root, 'CONFIG/system.webServer-defaultDocument/@enabled', new_resource.default_documents_enabled.to_s)
			current_default_documents = XPath.match(doc.root, 'CONFIG/system.webServer-defaultDocument/files/add/@value').map{|x| x.value}

			cmd = "#{appcmd(node)} set config /section:defaultDocument"

			if is_new_default_documents_enabled
				cmd << " /enabled:#{new_resource.default_documents_enabled}"
			end

			new_resource.default_documents.each do |document|
				if !current_default_documents.include? document
					cmd << " /+files.[value='#{document}']"
				end
			end

			current_default_documents.each do |document|
				if !new_resource.default_documents.include? document
					cmd << " /-files.[value='#{document}']"
				end
			end

			if cmd != "#{appcmd(node)} set config /section:defaultDocument"
				shell_out! cmd
				Chef::Log.info('Default Documents updated')
				was_updated = true
			end
		end
	end

	def mime_maps
		# handles mime maps
	  cmd = shell_out "#{appcmd(node)} list config /section:staticContent /config:* /xml"
	  if cmd.stderr.empty?
	    xml = cmd.stdout
	    doc = Document.new xml
			current_mime_maps = XPath.match(doc.root, 'CONFIG/system.webServer-staticContent/mimeMap').map{|x| "fileExtension='#{x.attribute 'fileExtension'}',mimeType='#{x.attribute 'mimeType'}'" }

			cmd = "#{appcmd(node)} set config /section:staticContent"

			new_resource.mime_maps.each do |mime_map|
				if !current_mime_maps.include? mime_map
					cmd << " /+\"[#{mime_map}]\""
				end
			end

			current_mime_maps.each do |mime_map|
				if !new_resource.mime_maps.include? mime_map
					cmd << " /+\"[#{mime_map}]\""
				end
			end

			if cmd != "#{appcmd(node)} set config /section:staticContent"
				shell_out! cmd
				Chef::Log.info('mime maps updated')
				was_updated = true
			end
		end
	end
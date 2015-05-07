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

	# handles default documents
  cmd = shell_out "#{appcmd(node)} list config /section:defaultDocument /config:* /xml"
  if cmd.stderr.empty?
    xml = cmd.stdout
    doc = Document.new xml
		current_default_documents = XPath.match(doc.root, 'defaultDocument/files/add/@value').map{|x| x.value}

		cmd = "#{appcmd(node)} set config /section:defaultDocument"

		new_resource.default_documents.each do |document|
			if !current_default_documents.include? document
				cmd << " /+files.[value='#{document}'"
			end
		end

		current_default_documents.each do |document|
			if !new_resource.default_documents.include? document
				cmd << " /-files.[value='#{document}'"
			end
		end

		if cmd != "#{appcmd(node)} set config /section:defaultDocument"
			was_updated = true
			shell_out! cmd
		end

		if was_updated
	    new_resource.updated_by_last_action(true)
		  Chef::Log.info('Default Documents updated')
	  else
	    Chef::Log.debug("#{new_resource} Default Documents exist - nothing to do")
		end
	end
end

def load_current_resource
	@current_resource = Chef::Resource::IisApp.new
  @current_resource.default_documents(new_resource.default_documents)
  @current_resource.default_documents_enabled(new_resource.default_documents_enabled)
end
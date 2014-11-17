#
# Author:: Justin Schuhmann
# Cookbook Name:: iis
# Resource:: lock
#
# Copyright:: 2011, Webtrends Inc.
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
include Windows::Helper
include REXML

action :config do
	unless @current_resource.exists
		cmd = "#{appcmd} lock config section:\"#{@new_resource.section}\""
		Chef::Log.debug(cmd)
		shell_out!(cmd, :returns => @new_resource.returns)
		Chef::Log.info("IIS Config command run")
	else
		Chef::Log.debug("#{@new_resource.section} already locked - nothing to do")
	end
end

def load_current_resource
	@current_resource = Chef::Resource::IisPool.new(@new_resource.section)
	@current_resource.section(@new_resource.section)
	cmd_current_values = "#{appcmd} list config \"\" -section:#{@new_resource.section} /config:* /xml"
	Chef::Log.debug(cmd_current_values)
	cmd_current_values = shell_out(cmd_current_values)
	if cmd_current_values.stderr.empty?
	    xml = cmd_current_values.stdout
	    doc = Document.new(xml)
	    overrideMode = XPath.first(doc.root, "CONFIG/@overrideMode").to_s == "Deny" ? true : false
	    @current_resource.exists = overrideMode
	end
end

private
def appcmd
  @appcmd ||= begin
    "#{node['iis']['home']}\\appcmd.exe"
  end
end

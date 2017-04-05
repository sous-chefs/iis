#
# Cookbook:: iis
# Resource:: root
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

include Opscode::IIS::Helper
include Opscode::IIS::Processors

# default documents
property :default_documents_enabled, [true, false], default: true
property :default_documents, Array, default: ['Default.htm', 'Default.asp', 'index.htm', 'index.html', 'iisstart.htm', 'default.aspx']
property :add_default_documents, Array, default: []
property :delete_default_documents, Array, default: []
property :add_mime_maps, Array, default: []
property :delete_mime_maps, Array, default: []
property :mime_maps, Array, default: Opscode::IIS::Helper.default_mime_types

load_current_value do |desired|
  default_documents desired.default_documents
  default_documents_enabled desired.default_documents_enabled
  mime_maps desired.mime_maps
end

action :config do
  was_updated = false

  was_updated = default_documents(new_resource.default_documents, new_resource.default_documents_enabled) | was_updated
  was_updated = mime_maps(new_resource.mime_maps) | was_updated

  if was_updated
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.debug("#{new_resource} - nothing to do")
  end
end

action :add do
  was_updated = false

  was_updated = default_documents(new_resource.add_default_documents, new_resource.default_documents_enabled, true, false) | was_updated
  was_updated = mime_maps(new_resource.add_mime_maps, true, false) | was_updated

  if was_updated
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.debug("#{new_resource} - nothing to do")
  end
end

action :delete do
  was_updated = false
  Chef::Log.info('test')
  Chef::Log.info(new_resource.delete_default_documents)
  Chef::Log.info(new_resource.default_documents_enabled)
  was_updated = default_documents(new_resource.delete_default_documents, new_resource.default_documents_enabled, false) | was_updated
  Chef::Log.info('test1')
  was_updated = mime_maps(new_resource.delete_mime_maps, false) | was_updated
  Chef::Log.info('test2')
  if was_updated
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.debug("#{new_resource} - nothing to do")
  end
end

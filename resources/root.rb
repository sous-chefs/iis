#
# Cookbook:: iis
# Resource:: root
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

include Opscode::IIS::Constants
include Opscode::IIS::Helper
include Opscode::IIS::Processors

property :default_documents_enabled, [true, false], default: true
property :default_documents, Array, default: Opscode::IIS::Constants.default_documents
property :mime_maps, Array, default: Opscode::IIS::Constants.default_mime_types
property :add_default_documents, Array, default: []
property :add_mime_maps, Array, default: []
property :delete_default_documents, Array, default: []
property :delete_mime_maps, Array, default: []

default_action :config

load_current_value do |desired|
  current_default_documents_object = current_default_documents_config
  return unless current_default_documents_object

  current_mime_maps = current_mime_maps_config
  return unless current_mime_maps_config

  default_documents_enabled bool(current_default_documents_object[:default_documents_enabled])
  default_documents current_default_documents_object[:default_documents]
  mime_maps current_mime_maps

  current_add_default_documents = desired.add_default_documents - current_default_documents_object[:default_documents]
  add_default_documents desired.add_default_documents - current_add_default_documents

  delete_default_documents desired.delete_default_documents - current_default_documents_object[:default_documents]

  current_add_mime_maps = desired.add_mime_maps - current_mime_maps
  add_mime_maps desired.add_mime_maps - current_add_mime_maps

  delete_mime_maps desired.delete_mime_maps - current_mime_maps
end

action :config do
  converge_if_changed :default_documents_enabled do
    set_default_documents_enabled(new_resource.default_documents_enabled)
  end

  converge_if_changed :default_documents do
    set_default_documents(new_resource.default_documents, current_resource.default_documents)
  end

  converge_if_changed :mime_maps do
    set_mime_maps(new_resource.mime_maps, current_resource.mime_maps)
  end
end

action :add do
  converge_if_changed :add_default_documents do
    set_default_documents(new_resource.add_default_documents, current_resource.add_default_documents, true, false)
  end

  converge_if_changed :add_mime_maps do
    set_mime_maps(new_resource.add_mime_maps, current_resource.add_mime_maps, true, false)
  end
end

action :delete do
  converge_if_changed :delete_default_documents do
    set_default_documents(new_resource.delete_default_documents, current_resource.delete_default_documents, false, true)
  end

  converge_if_changed :delete_mime_maps do
    set_mime_maps(new_resource.delete_mime_maps, current_resource.delete_mime_maps, false, true)
  end
end

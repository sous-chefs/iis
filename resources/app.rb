#
# Author:: Kendrick Martin (kendrick.martin@webtrends.com>)
# Cookbook:: iis
# Resource:: app
#
# Copyright:: 2011-2016, Webtrends Inc.
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

actions :add, :delete, :config
default_action :add

attribute :site_name, kind_of: String, name_attribute: true
attribute :path, kind_of: String, default: '/'
attribute :application_pool, kind_of: String
attribute :physical_path, kind_of: String
attribute :enabled_protocols, kind_of: String
attribute :default_documents, kind_of: Array, default: []
attribute :mime_maps, kind_of: Array, default: []

# default virtual directory settings
attribute :default_vdir_path, kind_of: String
attribute :default_vdir_physical_path, kind_of: String
attribute :default_vdir_username, kind_of: String, default: nil
attribute :default_vdir_password, kind_of: String, default: nil
attribute :default_vdir_logon_method, kind_of: Symbol, default: :ClearText, equal_to: [:Interactive, :Batch, :Network, :ClearText]
attribute :default_vdir_allow_sub_dir_config, kind_of: [TrueClass, FalseClass], default: true

attr_accessor :exists, :running

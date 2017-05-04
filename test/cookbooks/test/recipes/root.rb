#
# Cookbook:: test
# Recipe:: root
#
# copyright: 2017, Chef Software, Inc.
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

include_recipe 'iis'

iis_root 'adding test html' do
  add_default_documents ['test.html']
  add_mime_maps ['fileExtension=\'.dmg\',mimeType=\'application/octet-stream\'']
  action :add
end

iis_root 'remove mime types' do
  delete_mime_maps ['fileExtension=\'.rpm\',mimeType=\'audio/x-pn-realaudio-plugin\'', 'fileExtension=\'.msi\',mimeType=\'application/octet-stream\'']
  action :delete
end

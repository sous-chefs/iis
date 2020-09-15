include_recipe 'iis'

iis_manager 'IIS Manager' do
  port                      19500
  enable_remote_management  true
  log_directory             'C:\\CustomPath'
end

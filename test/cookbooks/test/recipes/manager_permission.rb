include_recipe 'iis'

iis_manager 'IIS Manager' do
  enable_remote_management true
end

iis_manager_permission 'Default Web Site' do
  users ['BUILTIN\\Users']
end

#NOTE
#dotnet 4.5.2 will not install remotely(over winrm) wihtout tricks.
#This is true even using the "offline" installer
#as it still uses remote restricted functions

log "dot net 4.5.2" do
  message "Dot net 4.5.2 installer requires a reboot to complete"
  level :warn
  action :nothing
end

wrapper_command = "#{Chef::Config[:file_cache_path]}\\install_dotnet452.cmd"
file wrapper_command do
  content "choco install dotnet4.5.2 -y"
  rights :full_control, "Administrators"
  rights :read_execute, "Everyone"
end

execute "Install Dotnet 4.5.2" do
  command "psexec -s -i -accepteula #{wrapper_command}"
  action :run
  not_if {
    registry_key_exists?("HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\.NETFramework\\v4.0.30319\\SKUs\\.NETFramework,Version=v4.5.2",
    :x86_64)
  }
  notifies :write, 'log[dot net 4.5.2]', :delayed
end

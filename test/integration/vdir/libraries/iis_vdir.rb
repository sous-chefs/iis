# encoding: utf-8
# frozen_string_literal: true
# check for virtual directories in IIS
# Usage:
# describe iis_vdir('Default Web Site', '/vdir_test') do
#   it { should exist }
#   it { should have_path('/vdir_test') }
#   it { should have_physical_path('C:\\inetpub\\wwwroot\\vdir_test') }
#   it { should have_username('vagrant') }
#   it { should have_password('vagrant') }
#   it { should have_logon_method('ClearText') }
#   it { should have_allow_sub_dir_config(false) }
# end
#
# Note: this is only supported in windows 2012 and later

class IisVdir < Inspec.resource(1)
  name 'iis_vdir'
  desc 'Tests IIS application configuration on windows. Supported in server 2012+ only'
  example "
    describe iis_vdir('Default Web Site', '/vdir_test') do
      it { should exist }
      it { should have_path('/vdir_test') }
      it { should have_physical_path('C:\\inetpub\\wwwroot\\vdir_test') }
      it { should have_username('vagrant') }
      it { should have_password('vagrant') }
      it { should have_logon_method('ClearText') }
      it { should have_allow_sub_dir_config(false) }
    end
  "

  def initialize(path, application_name)
    @path = path
    @application_name = application_name
    @cache = nil

    @vdir_provider = VdirProvider.new(inspec)

    # verify that this resource is only supported on Windows
    skip_resource 'The `iis_vdir` resource is not supported on your OS.' unless inspec.os.windows?
  end

  def application_name
    iis_vdir[:application_name]
  end

  def path
    iis_vdir[:path]
  end

  def physical_path
    iis_vdir[:physical_path]
  end

  def username
    iis_vdir[:username]
  end

  def password
    iis_vdir[:password]
  end

  def logon_method
    iis_vdir[:logon_method]
  end

  def allow_sub_dir_config
    iis_vdir[:allow_sub_dir_config]
  end

  def exists?
    !iis_vdir[:path].empty?
  end

  def has_application_name?(application_name)
    iis_vdir[:application_name] == application_name
  end

  def has_path?(path)
    iis_vdir[:path] == path
  end

  def has_physical_path?(physical_path)
    iis_vdir[:physical_path] == physical_path
  end

  def has_password?(password)
    iis_vdir[:password] == password
  end

  def has_username?(username)
    iis_vdir[:username] == username
  end

  def has_logon_method?(method)
    iis_vdir[:logon_method] == method
  end

  def has_allow_sub_dir_config?(allow)
    iis_vdir[:allow_sub_dir_config] == allow
  end

  def to_s
    "iis_vdir '#{@application_name}#{@path}'"
  end

  def iis_vdir
    return @cache unless @cache.nil?
    @cache = @vdir_provider.iis_vdir(@path, @application_name) unless @vdir_provider.nil?
  end
end

class VdirProvider
  attr_reader :inspec

  def initialize(inspec)
    @inspec = inspec
  end

  # want to populate everything using one powershell command here and spit it out as json
  def iis_vdir(path, application_name)
    site_app = application_name.split('/', 2)

    command = "Import-Module WebAdministration; Get-WebVirtualDirectory -Site \"#{site_app[0]}\""
    command = "#{command.dup} -Application \"#{site_app[1]}\"" if site_app.length > 1
    command = "#{command.dup} -Name \"#{path}\" | Select-Object path, physicalPath, userName, password, logonMethod, allowSubDirConfig, PSPath, ItemXPath | ConvertTo-Json"
    cmd = @inspec.command(command)

    begin
      vdir = JSON.parse(cmd.stdout)
      Log.info(vdir)
    rescue JSON::ParserError => _e
      return {}
    end

    # map our values to a hash table
    {
      application_name: application_name,
      path: path,
      physical_path: vdir['physicalPath'],
      username: vdir['userName'],
      password: vdir['password'],
      logon_method: vdir['logonMethod'],
      allow_sub_dir_config: vdir['allowSubDirConfig'],
    }
  end
end

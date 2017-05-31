# encoding: utf-8
# frozen_string_literal: true
# check for application modules in IIS
# Usage:
# describe iis_module('module_name', 'Default Web Site') do
#   it { should exist }
#   it { should have_name('module_name') }
#   it { should have_type('System.Web.Security.FileAuthorizationModule, System.Web, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a') }
# end
#
# Note: this is only supported in windows 2012 and later

class IisModule < Inspec.resource(1)
  name 'iis_module'
  desc 'Tests IIS module configuration on windows. Supported in server 2012+ only'
  example "
    describe iis_module('module_name', 'Default Web Site') do
      it { should exist }
      it { should have_name('module_name') }
      it { should have_type('System.Web.Security.FileAuthorizationModule, System.Web, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a') }
    end
  "

  def initialize(module_name, application)
    @module_name = module_name
    @application = application
    @cache = nil

    @module_provider = ModuleProvider.new(inspec)

    # verify that this resource is only supported on Windows
    return skip_resource 'The `iis_module` resource is not supported on your OS.' unless inspec.os.windows?
  end

  def name
    iis_module[:name]
  end

  def type
    iis_module[:type]
  end

  def pre_condition
    iis_module[:pre_condition]
  end

  def exists?
    !iis_module.nil? && !iis_module[:name].nil?
  end

  def has_name?(module_name)
    iis_module.nil? ? false : iis_module[:name] == module_name
  end

  def has_type?(module_type)
    iis_module.nil? ? false : iis_module[:type] == module_type
  end

  def has_pre_condition?(pre_condition)
    iis_module.nil? ? false : iis_module[:pre_condition] == pre_condition
  end

  def to_s
    "iis_module `#{@module_name}` - `#{@application}`"
  end

  def iis_module
    return @cache unless @cache.nil?
    @cache = @module_provider.iis_module(@module_name, @application) unless @module_provider.nil?
  end
end

class ModuleProvider
  attr_reader :inspec

  def initialize(inspec)
    @inspec = inspec
  end

  # want to populate everything using one powershell command here and spit it out as json
  def iis_module(module_name, application)
    command = "Import-Module WebAdministration; Get-WebManagedModule -Name '#{module_name}' -PSPath 'IIS:\\sites\\#{application}' | Select-Object name, type, preCondition | ConvertTo-Json"
    cmd = @inspec.command(command)

    begin
      mod = JSON.parse(cmd.stdout)
    rescue JSON::ParserError => _e
      return {}
    end

    # map our values to a hash table
    {
      name: mod['name'],
      type: mod['type'],
      pre_condition: mod['preCondition'],
    }
  end
end

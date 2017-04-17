# encoding: utf-8
# frozen_string_literal: true
# check for sections in IIS
# Usage:
# describe iis_section('//staticContent', 'Default Web Site') do
#   it { should exist }
#   it { should have_override_mode('Allow') }
#   it { should have_override_mode_effective('Allow') }
# end
#
# Note: this is only supported in windows 2012 and later

class IisSection < Inspec.resource(1)
  name 'iis_section'
  desc 'Tests IIS section on windows. Supported in server 2012+ only'
  example "
    describe iis_section('//staticContent', 'Default Web Site') do
      it { should exist }
      it { should have_override_mode('Allow') }
      it { should have_override_mode_effective('Allow') }
    end
  "

  def initialize(section, location)
    @section = section
    @location = location
    @cache = nil

    @section_provider = SectionProvider.new(inspec)

    # verify that this resource is only supported on Windows
    skip_resource 'The `iis_section` resource is not supported on your OS.' unless inspec.os.windows?
  end

  def is_locked
    iis_section[:is_locked]
  end

  def override_mode
    iis_section[:override_mode]
  end

  def override_mode_effective
    iis_section[:override_mode_effective]
  end

  def exists?
    !iis_section[:override_mode].empty?
  end

  def has_locked?(locked)
    iis_section[:is_locked] == locked
  end

  def has_override_mode?(override_mode)
    iis_section[:override_mode] == override_mode
  end

  def has_override_mode_effective?(effective_override)
    iis_section[:override_mode_effective] == effective_override
  end

  def to_s
    "iis_section section: '#{@section}' - location: '#{@location}'"
  end

  def iis_section
    return @cache unless @cache.nil?
    @cache = @section_provider.iis_section(@section, @location) unless @section_provider.nil?
  end
end

class SectionProvider
  attr_reader :inspec

  def initialize(inspec)
    @inspec = inspec
  end

  # want to populate everything using one powershell command here and spit it out as json
  def iis_section(section, location)
    command = "Import-Module WebAdministration; get-webconfiguration -Filter '#{section}' -PSPath 'MACHINE/WEBROOT/APPHOST' -Location '#{location}' -metadata | Select-Object IsLocked, OverrideMode, OverrideModeEffective | ConvertTo-JSON"
    cmd = @inspec.command(command)
    override_mode_enumeration = %w(N/A Inherit Allow Deny Unknown)

    begin
      section = JSON.parse(cmd.stdout)
    rescue JSON::ParserError => _e
      return {}
    end

    # map our values to a hash table
    {
      is_locked: section['IsLocked'],
      override_mode: override_mode_enumeration[section['OverrideMode']],
      override_mode_effective: override_mode_enumeration[section['OverrideModeEffective']],
    }
  end
end

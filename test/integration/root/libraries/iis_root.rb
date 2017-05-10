# encoding: utf-8
# frozen_string_literal: true
# check for application pools in IIS
# Usage:
# describe iis_root() do
#   it { should have_document('index.htm') }
#   it { should have_mime("fileExtension='.323',mimeType='text/h323'") }
# end
#
# Note: this is only supported in windows 2012 and later

class IisRoot < Inspec.resource(1)
  name 'iis_root'
  desc 'Tests IIS default documents and mime types configuration on windows. Supported in server 2012+ only'
  example "
    describe iis_root() do
      it { should have_document('index.htm') }
      it { should have_mime(\"fileExtension='.323',mimeType='text/h323'\") }
    end
  "

  def initialize
    @cache = nil

    @root_provider = RootProvider.new(inspec)

    # verify that this resource is only supported on Windows
    return skip_resource 'The `iis_root` resource is not supported on your OS.' unless inspec.os.windows?
  end

  def default_documents
    iis_root[:default_documents]
  end

  def mime_maps
    iis_root[:mime_maps]
  end

  def has_document?(document)
    iis_root.nil? ? false : (iis_root[:default_documents].include? document)
  end

  def has_mime?(mime)
    iis_root.nil? ? false : (iis_root[:mime_maps].include? mime)
  end

  def to_s
    'iis_root config'
  end

  def iis_root
    return @cache unless @cache.nil?
    @cache = @root_provider.iis_root unless @root_provider.nil?
  end
end

class RootProvider
  attr_reader :inspec

  def initialize(inspec)
    @inspec = inspec
  end

  # want to populate everything using one powershell command here and spit it out as json
  def iis_root
    command_default_documents = 'Import-Module WebAdministration; Get-WebConfiguration -Filter /system.webServer/defaultDocument/files/add -PSPath MACHINE/WEBROOT/APPHOST | Select-Object value | ConvertTo-JSON'
    cmd_default_documents = @inspec.command(command_default_documents)

    command_mime_maps = 'Get-WebConfiguration -Filter system.webServer/staticContent/mimeMap -PSPath MACHINE/WEBROOT/APPHOST | Select-Object fileExtension, mimeType | ConvertTo-Json'
    cmd_mime_maps = @inspec.command(command_mime_maps)

    begin
      docs = JSON.parse(cmd_default_documents.stdout)
      mimes = JSON.parse(cmd_mime_maps.stdout)
    rescue JSON::ParserError => _e
      return {}
    end

    default_documents = []
    docs.each { |doc| default_documents.push(doc['value']) }

    mime_maps = []
    mimes.each { |mime| mime_maps.push("fileExtension='#{mime['fileExtension']}',mimeType='#{mime['mimeType']}'") }

    # map our values to a hash table
    {
      default_documents: default_documents,
      mime_maps: mime_maps,
    }
  end
end

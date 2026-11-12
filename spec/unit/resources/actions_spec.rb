# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'

# Exercise the actions with Windows command output as the external boundary.
# No IIS helper or action implementation is replaced by these stubs.
RSpec.shared_context 'IIS command boundary' do
  let(:commands) { [] }
  let(:command_output) { proc { |_command| '' } }
  let(:command_status) { 0 }

  def command_result(command)
    OpenStruct.new(stdout: command_output.call(command), stderr: '', exitstatus: command_status)
  end

  stubs_for_resource do |resource|
    next unless resource.resource_name.to_s.start_with?('iis_')

    allow(resource).to receive(:shell_out) { |command, *_| command_result(command) }
    allow(resource).to receive(:shell_out!) do |command, *_|
      commands << command unless command.include?(' list ') || command.include?(' show ')
      command_result(command)
    end
  end

  stubs_for_provider do |provider|
    next unless provider.new_resource.resource_name.to_s.start_with?('iis_')

    allow(provider).to receive(:shell_out) { |command, *_| command_result(command) }
    allow(provider).to receive(:shell_out!) do |command, *_|
      commands << command
      command_result(command)
    end
    allow(provider).to receive(:powershell_out!).and_return(OpenStruct.new(stdout: 'True', stderr: ''))
  end
end

describe 'iis_config actions' do
  platform 'windows', '2019'
  include_context 'IIS command boundary'
  step_into :iis_config

  [:set, :clear].each do |operation|
    context operation do
      recipe do
        iis_config '/section:system.webServer/httpErrors' do
          action operation
        end
      end

      it 'passes the requested operation and configuration to appcmd' do
        chef_run
        expect(commands).to contain_exactly(end_with(" #{operation} config /section:system.webServer/httpErrors"))
      end
    end
  end
end

describe 'iis_config_property actions' do
  platform 'windows', '2019'
  step_into :iis_config_property
  before { stub_command(/Get-WebConfiguration/).and_return(true) }

  [:set, :add, :remove].each do |operation|
    context operation do
      recipe do
        iis_config_property 'value' do
          ps_path 'MACHINE/WEBROOT/APPHOST'
          location 'Example'
          filter 'system.webServer/defaultDocument/files'
          value 'index.html'
          action operation
        end
      end

      it 'uses the matching Windows configuration operation and location' do
        script = chef_run.powershell_script('Set MACHINE/WEBROOT/APPHOSTExample/system.webServer/defaultDocument/files/value')
        verb = { set: 'Set', add: 'Add', remove: 'Remove' }.fetch(operation)
        expect(script.code).to include("#{verb}-WebConfigurationProperty", '-location "Example"', 'index.html')
        expect(script.only_if.first.command).to include('Get-WebConfiguration')
      end
    end
  end
end

describe 'iis_manager action' do
  platform 'windows', '2019'
  step_into :iis_manager
  recipe do
    iis_manager 'remote manager' do
      port 8173
      log_directory 'C:/iis-logs'
      enable_remote_management false
    end
  end

  it 'installs the management service and applies explicit registry values' do
    expect(chef_run).to install_iis_install('Web-Mgmt-Service').with(additional_components: ['IIS-ManagementService'])
    expect(chef_run).to create_directory('C:/iis-logs').with(recursive: true)
    values = chef_run.registry_key('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WebManagement\Server').unscrubbed_values
    expect(values).to include({ name: 'EnableRemoteManagement', type: :dword, data: 0 }, { name: 'Port', type: :dword, data: 8173 })
  end

  it 'reserves the custom port, binds its certificate and starts WMSVC' do
    expect(chef_run).to create_iis_http_acl('https://*:8173/').with(user: 'NT SERVICE\WMSvc')
    expect(chef_run).to create_iis_certificate_binding('WMSVC').with(port: 8173)
    expect(chef_run).to enable_service('WMSVC')
    expect(chef_run).to start_service('WMSVC')
  end
end

describe 'iis_manager_permission action' do
  platform 'windows', '2019'
  step_into :iis_manager_permission
  before { stub_command(/GetAuthorizedUsers/).and_return(true) }
  recipe do
    iis_manager_permission 'Example' do
      users ['alice']
      groups ['operators']
    end
  end

  it 'distinguishes user and group grants and revokes principals omitted from the definition' do
    script = chef_run.powershell_script('Set permissions for Path Example')
    expect(script.code).to include('Grant($principal, "Example", $false)', 'Grant($principal, "Example", $true)', 'Revoke($_.Name, "Example")')
    expect(script.code).to include('"alice"', '"operators"')
    expect(script).to notify('service[WMSVC]').to(:restart).delayed
  end
end

describe 'iis_app action' do
  platform 'windows', '2019'
  include_context 'IIS command boundary'
  step_into :iis_app
  recipe do
    iis_app 'Example' do
      path '/api'
      physical_path 'C:/sites/api'
      application_pool 'ApiPool'
    end
  end

  it 'creates the application with its explicit path and pool' do
    chef_run
    expect(commands).to include(a_string_including(' add app /site.name:"Example"', '/path:"/api"', '/applicationPool:"ApiPool"', '/physicalPath:"C:\\sites\\api"'))
  end
end

describe 'iis_site action' do
  platform 'windows', '2019'
  include_context 'IIS command boundary'
  step_into :iis_site
  recipe do
    iis_site 'Example' do
      path 'C:/sites/example'
      port 8080
      host_header 'example.test'
    end
  end

  it 'creates the site on the requested binding and physical path' do
    chef_run
    expect(commands).to include(a_string_including(' add site /name:"Example"', '/physicalPath:"C:\\sites\\example"', '/bindings:http/*:8080:example.test'))
  end
end

describe 'iis_vdir action' do
  platform 'windows', '2019'
  include_context 'IIS command boundary'
  step_into :iis_vdir
  recipe do
    iis_vdir 'Example/api' do
      path '/assets'
      physical_path 'C:/sites/assets'
    end
  end

  it 'creates the virtual directory under the requested application' do
    chef_run
    expect(commands).to include(a_string_including(' add vdir /app.name:"Example/api"', '/path:"/assets"', '/physicalPath:"C:\\sites\\assets"'))
  end
end

describe 'iis_pool action' do
  platform 'windows', '2019'
  include_context 'IIS command boundary'
  step_into :iis_pool
  recipe do
    iis_pool 'ApiPool' do
      no_managed_code true
    end
  end

  it 'creates an unmanaged application pool without requiring node attributes' do
    chef_run
    expect(commands).to include(a_string_including(' add apppool /name:"ApiPool"', '/managedRuntimeVersion:'))
  end
end

describe 'iis_http_acl actions' do
  platform 'windows', '2019'
  include_context 'IIS command boundary'
  step_into :iis_http_acl

  context 'creating a missing reservation' do
    recipe do
      iis_http_acl 'https://*:8173/' do
        user 'NT SERVICE\WMSvc'
      end
    end

    it 'reserves the URL for the requested service account' do
      chef_run
      expect(commands).to include(a_string_including('http add urlacl url=https://*:8173/ user="NT SERVICE\WMSvc"'))
    end
  end

  context 'deleting an existing reservation' do
    let(:command_output) { proc { |_command| "Reserved URL : https://*:8173/\nUser: NT SERVICE\\WMSvc" } }
    recipe do
      iis_http_acl 'https://*:8173/' do
        action :delete
      end
    end

    it 'removes the requested URL reservation' do
      chef_run
      expect(commands).to include(end_with('http delete urlacl url=https://*:8173/'))
    end
  end

  context 'creating a reservation using an SDDL' do
    recipe do
      iis_http_acl 'https://*:8173/' do
        sddl 'D:(A;;GX;;;BU)'
      end
    end

    it 'applies the supplied security descriptor instead of an empty user' do
      chef_run
      expect(commands).to include(end_with('http add urlacl url=https://*:8173/ sddl="D:(A;;GX;;;BU)"'))
    end
  end
end

describe 'iis_certificate_binding actions' do
  platform 'windows', '2019'
  include_context 'IIS command boundary'
  step_into :iis_certificate_binding
  let(:thumbprint) { 'a' * 40 }

  context 'creating a missing binding by hash' do
    let(:command_status) { 1 }
    recipe do
      iis_certificate_binding 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' do
        name_kind :hash
        port 8443
      end
    end

    it 'binds the existing certificate to the requested endpoint' do
      chef_run
      expect(commands).to include(a_string_including('http add sslcert ipport=0.0.0.0:8443', "certhash=#{thumbprint}", 'certstorename=MY'))
    end
  end

  context 'deleting an existing binding' do
    let(:command_output) { proc { |_command| "Certificate Hash : #{thumbprint}" } }
    recipe do
      iis_certificate_binding 'unused subject' do
        port 8443
        action :delete
      end
    end

    it 'removes the binding without deleting its shared certificate' do
      chef_run
      expect(commands).to contain_exactly(end_with('http delete sslcert ipport=0.0.0.0:8443'))
    end
  end

  context 'creating a binding by subject' do
    let(:command_status) { 1 }
    stubs_for_provider('iis_certificate_binding') do |provider|
      allow(provider).to receive(:powershell_out!).with(/gci cert:/)
                                                  .and_return(OpenStruct.new(stdout: "\uFEFF#{thumbprint}\n", stderr: '', error?: false))
    end
    recipe do
      iis_certificate_binding '*.example.test' do
        port 8443
      end
    end

    it 'resolves the subject and removes a returned UTF-8 BOM from the certificate hash' do
      chef_run
      expect(commands).to include(a_string_including("certhash=#{thumbprint} appid="))
    end
  end
end

describe 'iis_section actions' do
  platform 'windows', '2019'
  include_context 'IIS command boundary'
  step_into :iis_section
  let(:command_output) { proc { |_command| '<appcmd><CONFIG overrideMode="Deny" /></appcmd>' } }
  recipe do
    iis_section 'system.webServer/security/authentication/basicAuthentication' do
      site 'Example'
      application_path '/api'
      action :unlock
    end
  end

  it 'unlocks the section for the requested application' do
    chef_run
    expect(commands).to include(a_string_including('set config "MACHINE/WEBROOT/APPHOST/Example/api"', '-overrideMode:Allow'))
  end
end

describe 'iis_module action' do
  platform 'windows', '2019'
  include_context 'IIS command boundary'
  step_into :iis_module
  let(:command_output) do
    proc do |command|
      if command.include?('list config')
        last_override = commands.reverse.find { |written| written.include?('-overrideMode:') }
        mode = last_override ? last_override[/overrideMode:(\w+)/, 1] : 'Deny'
        "<appcmd><CONFIG overrideMode=\"#{mode}\" /></appcmd>"
      else
        ''
      end
    end
  end
  recipe do
    iis_module 'ExampleModule' do
      type 'Example.Module'
      application 'Example/api'
    end
  end

  it 'adds the managed module to the requested application' do
    chef_run
    expect(commands).to include(a_string_including('add module /module.name:"ExampleModule"', '/app.name:"Example/api"', '/type:"Example.Module"'))
    expect(commands.last).to include('-overrideMode:Deny')
  end
end

describe 'iis_root action' do
  platform 'windows', '2019'
  include_context 'IIS command boundary'
  step_into :iis_root
  let(:command_output) do
    proc do |command|
      if command.include?('defaultDocument')
        '<appcmd><CONFIG><system.webServer-defaultDocument enabled="true"><files><add value="old.html" /></files></system.webServer-defaultDocument></CONFIG></appcmd>'
      else
        '<appcmd><CONFIG><system.webServer-staticContent /></CONFIG></appcmd>'
      end
    end
  end
  recipe do
    iis_root 'defaults' do
      default_documents ['index.html']
      mime_maps []
    end
  end

  it 'replaces the default documents while preserving unrelated configuration sections' do
    chef_run
    expect(commands).to contain_exactly(a_string_including('/section:defaultDocument', "/+files.[value='index.html']", "/-files.[value='old.html']"))
  end
end

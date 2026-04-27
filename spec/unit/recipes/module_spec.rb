require 'spec_helper'

describe 'test::module' do
  cached(:chef_run) { test_cookbook_runner.converge(described_recipe) }

  let(:legacy_module_components) do
    %w(
      IIS-ApplicationInit
      IIS-NetFxExtensibility
      IIS-ASPNET
      NetFx4Extended-ASPNET45
      IIS-NetFxExtensibility45
      IIS-ASPNET45
      IIS-BasicAuthentication
      IIS-DigestAuthentication
      IIS-WindowsAuthentication
      IIS-CGI
      IIS-HttpCompressionDynamic
      IIS-HttpCompressionStatic
      IIS-FTPServer
      IIS-FTPSvc
      IIS-FTPExtensibility
      IIS-IIS6ManagementCompatibility
      IIS-Metabase
      IIS-ISAPIFilter
      IIS-ISAPIExtensions
      IIS-CustomLogging
      IIS-ManagementConsole
      IIS-ManagementService
      IIS-URLAuthorization
      IIS-RequestFiltering
      IIS-IPSecurity
      IIS-HttpTracing
    )
  end

  it 'installs the legacy module feature set with iis_install' do
    expect(chef_run).to install_iis_install('install IIS legacy module components').with(
      additional_components: legacy_module_components,
      start_iis: true
    )
  end

  it 'unlocks authentication sections explicitly' do
    expect(chef_run).to unlock_iis_section('unlocks anonymous authentication control in web.config')
    expect(chef_run).to unlock_iis_section('unlocks basic authentication control in web.config')
    expect(chef_run).to unlock_iis_section('unlocks digest authentication control in web.config')
    expect(chef_run).to unlock_iis_section('unlocks windows authentication control in web.config')
  end
end

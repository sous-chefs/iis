require 'spec_helper'

describe 'test::site' do
  cached(:chef_run) { test_cookbook_runner.converge(described_recipe) }

  it 'installs FTP prerequisites with iis_install' do
    expect(chef_run).to install_iis_install('install IIS FTP components').with(
      additional_components: %w(IIS-FTPServer IIS-FTPSvc IIS-FTPExtensibility),
      start_iis: true
    )
  end

  it 'manages sites and pools through custom resources' do
    expect(chef_run).to add_iis_site('test')
    expect(chef_run).to add_iis_site('test2')
    expect(chef_run).to add_iis_pool('Test AppPool')
    expect(chef_run).to add_iis_app('MyTest')
  end
end

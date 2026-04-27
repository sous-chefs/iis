require 'spec_helper'

describe 'test::pool' do
  cached(:chef_run) { test_cookbook_runner.converge(described_recipe) }

  it 'installs IIS before configuring pools' do
    expect(chef_run).to install_iis_install('install IIS')
  end

  it 'configures application pools through custom resources' do
    expect(chef_run).to add_iis_pool('testapppool').with(
      identity_type: :SpecificUser,
      periodic_restart_schedule: %w(06:00:00 14:00:00 17:00:00),
      recycle_after_requests: 1024
    )
  end
end

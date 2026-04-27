require 'spec_helper'

describe 'test::disable_default' do
  cached(:chef_run) { test_cookbook_runner.converge(described_recipe) }

  it 'removes the default site via custom resources' do
    expect(chef_run).to stop_iis_site('Default Web Site')
    expect(chef_run).to delete_iis_site('Default Web Site')
  end

  it 'removes the default application pool via custom resources' do
    expect(chef_run).to stop_iis_pool('DefaultAppPool')
    expect(chef_run).to delete_iis_pool('DefaultAppPool')
  end
end

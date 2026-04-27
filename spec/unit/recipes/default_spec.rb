require 'spec_helper'

describe 'test::default' do
  cached(:chef_run) { test_cookbook_runner.converge(described_recipe) }

  it 'installs IIS via the custom resource API' do
    expect(chef_run).to install_iis_install('install IIS').with(start_iis: true)
  end
end

# frozen_string_literal: true

require 'chefspec'
require 'chefspec/policyfile'

RSpec.configure do |config|
  config.color = true               # Use color in STDOUT
  config.formatter = :documentation # Use the specified formatter
  config.log_level = :error         # Avoid deprecation notice SPAM
  config.platform = 'windows'
  config.version = '2019'
end

def test_cookbook_runner
  ChefSpec::SoloRunner.new(
    cookbook_path: RSpec.configuration.cookbook_path,
    platform: 'windows',
    version: '2019'
  )
end

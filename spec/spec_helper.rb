require 'chefspec'
require 'chefspec/berkshelf'
require 'fileutils'
require 'tmpdir'

RSpec.configure do |config|
  config.color = true               # Use color in STDOUT
  config.formatter = :documentation # Use the specified formatter
  config.log_level = :error         # Avoid deprecation notice SPAM
  config.platform = 'windows'
  config.version = '2019'
end

COOKBOOK_ROOT = File.expand_path('..', __dir__)
CHEFSPEC_COOKBOOK_PATH = File.join(Dir.tmpdir, 'iis-chefspec-cookbooks')
TEST_COOKBOOK_ROOT = File.join(COOKBOOK_ROOT, 'test', 'cookbooks', 'test')

FileUtils.rm_rf(CHEFSPEC_COOKBOOK_PATH)
FileUtils.mkdir_p(CHEFSPEC_COOKBOOK_PATH)
FileUtils.ln_sf(COOKBOOK_ROOT, File.join(CHEFSPEC_COOKBOOK_PATH, 'iis'))
FileUtils.ln_sf(TEST_COOKBOOK_ROOT, File.join(CHEFSPEC_COOKBOOK_PATH, 'test'))

Chef::Config[:cookbook_path] = [CHEFSPEC_COOKBOOK_PATH]

def test_cookbook_runner
  ChefSpec::SoloRunner.new(
    cookbook_path: [CHEFSPEC_COOKBOOK_PATH],
    platform: 'windows',
    version: '2019'
  )
end

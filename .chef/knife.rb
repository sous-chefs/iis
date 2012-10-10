current_dir = File.dirname(__FILE__)
user_email = `git config --get user.email`
home_dir = ENV['HOME'] || ENV['HOMEDRIVE']
org = ENV['chef_org'] || 'ndirect'

knife_override = "#{home_dir}/.chef/knife_override.rb"

chef_server_url          "https://chefp01.nordstrom.net/organizations/#{org}"
log_level                :info
log_location             STDOUT
node_name                ENV['USER'] || ENV['USERNAME']
client_key               "#{home_dir}/.chef/#{node_name}.pem"
cache_type               'BasicFile'
cache_options( :path => "#{home_dir}/.chef/checksums" )

cookbook_path            ["#{current_dir}/../../../cookbooks"]
cookbook_copyright       "Nordstrom, Inc."
cookbook_license         "none"
cookbook_email           "#{user_email}"

http_proxy               "http://webproxysea.nordstrom.net:80"
https_proxy              "http://webproxysea.nordstrom.net:80"
no_proxy                 "localhost, 10.*, *.nordstrom.net, *.dev.nordstrom.com"

# Allow overriding values in this knife.rb
Chef::Config.from_file(knife_override) if File.exist?(knife_override)

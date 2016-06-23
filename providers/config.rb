#
# Author:: Justin Schuhmann (jmschu02@gmail.com)
# Cookbook Name:: iis
# Resource:: config
#

require 'chef/mixin/shell_out'
require 'rexml/document'

include Chef::Mixin::ShellOut
include REXML
include Opscode::IIS::Helper
include Opscode::IIS::Processors

action :set do
  if @current_resource.is_new
    config
  else
    Chef::Log.debug("#{new_resource} config value is the same - nothing to do")
  end
end

action :clear do
  if @current_resource.is_new
    config(:clear)
  else
    Chef::Log.debug("#{new_resource} config value is already empty - nothing to do")
  end
end

def config(action = :set)
  cmd = "#{appcmd(node)} #{action} config"
  cmd << " \"#{new_resource.zone}\"" if new_resource.zone
  cmd << " /commit:\"#{new_resource.commit}\"" if new_resource.commit
  cmd << " /section:\"#{new_resource.section}\"" if new_resource.section
  if action == :set
    new_resource.property.each do |key, value|
      cmd << " /\"#{key}\":\"#{value}\"" if key && value
    end
  end 
  Chef::Log.debug(cmd)
  shell_out!(cmd, returns: new_resource.returns)
  new_resource.updated_by_last_action(true)
end

def load_current_resource
  @current_resource = Chef::Resource::IisConfig.new(new_resource.name)
  @current_resource.section(new_resource.section)
  @current_resource.commit(new_resource.commit)
  @current_resource.property(new_resource.property)
  @current_resource.is_new = false

  cmd = "#{appcmd(node)} list config"
  cmd << " \"#{new_resource.zone}\"" if new_resource.zone
  cmd << " /commit:\"#{new_resource.commit}\"" if new_resource.commit
  cmd << " /section:\"#{new_resource.section}\"" if new_resource.section
  Chef::Log.debug(cmd)
  cmd = shell_out(cmd)
  if cmd.stderr.empty?
    xml = cmd.stdout
    Chef::Log.debug(xml)
    doc = Document.new(xml)
    if new_resource.action.include? :set
      new_resource.property.each do |key, value|
        Chef::Log.debug("key, value: #{key}, #{value}")
        if key.include? '.'
          key_xpath = key.split('.').join('/').insert(key.rindex('.') + 1, '@')
        else
          key_xpath = "@#{key}"
        end
        if new_resource.section.include? "/"
          xpath = new_resource.section.split('/')
          xpath.shift
          if !xpath.is_a?(String)
            xpath = xpath.join('/')
          end
          xpath = "#{xpath}/#{key_xpath}"
        else
          xpath = "#{new_resource.section}/#{key_xpath}" 
        end
        Chef::Log.debug("xpath: #{xpath}")
        @current_resource.is_new = @current_resource.is_new | new_value?(doc.root, xpath, value)
        if @current_resource.is_new
          break
        end
      end
    elsif new_resource.action.include? :clear
      xpath = new_resource.section
      if xpath.include? "/"
        xpath = new_resource.section.split('/')
        xpath.shift
        if !xpath.is_a?(String)
          xpath = xpath.join('/')
        end
      end
      xpath = "#{xpath}/@*"
      @current_resource.is_new = XPath.match(doc.root, xpath).length != 0
    end
  else
    log "Failed to run iis_config action :load_current_resource, #{cmd.stderr}" do
      level :warn
    end
  end
end
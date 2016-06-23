#
# Author:: Justin Schuhmann (jmschu02@gmail.com)
# Cookbook Name:: iis
# Resource:: config
#

actions :clear, :set
default_action :set

attribute :section, kind_of: String, name_attribute: true
attribute :commit, kind_of: String, :required => false
attribute :zone, kind_of: String, :required => false
attribute :property, kind_of: Hash, default: {}, :required => false
attribute :returns, kind_of: [Integer, Array], default: 0, :required => false

attr_accessor :is_new
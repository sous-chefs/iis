actions :config

attribute :allowed_file_extensions, :kind_of => [String, Array], :default => %w()
attribute :excluded_file_extensions, :kind_of => [String, Array], :default => %w()

default_action :config

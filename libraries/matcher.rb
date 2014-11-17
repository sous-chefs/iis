if defined?(ChefSpec)

  def config_iis_config(command)
    ChefSpec::Matchers::ResourceMatcher.new(:iis_config, :config, command)
  end

  [:config, :add, :delete].each do |action|
    self.class.send(:define_method, "#{action}_iis_app", proc  do |app_name|
      ChefSpec::Matchers::ResourceMatcher.new(:iis_app, action, app_name)
    end
    )
  end

  [:add, :delete].each do |action|
    self.class.send(:define_method, "#{action}_iis_module", proc do |module_name|
      ChefSpec::Matchers::ResourceMatcher.new(:iis_module, action, module_name)
    end
    )
  end

  [:add, :config, :delete, :start, :stop, :restart, :recycle].each do |action|
    self.class.send(:define_method, "#{action}_iis_pool", proc do |pool_name|
      ChefSpec::Matchers::ResourceMatcher.new(:iis_pool, action, pool_name)
    end
    )
  end

  [:add, :delete, :start, :stop, :restart, :config].each do |action|
    self.class.send(:define_method, "#{action}_iis_site", proc do |site_name|
      ChefSpec::Matchers::ResourceMatcher.new(:iis_site, action, site_name)
    end
    )
  end

  define_method = (Gem.loaded_specs["chefspec"].version < Gem::Version.new('4.1.0')) ?
    ChefSpec::Runner.method(:define_runner_method) :
    ChefSpec.method(:define_matcher)

  define_method.call :iis_app
  define_method.call :iis_config
  define_method.call :iis_module
  define_method.call :iis_pool
  define_method.call :iis_site
end

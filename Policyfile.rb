# frozen_string_literal: true

name 'iis'
default_source :supermarket

run_list 'test::default'

cookbook 'iis', path: '.'
cookbook 'test', path: 'test/cookbooks/test'

Dir.glob('test/cookbooks/test/recipes/*.rb').sort.each do |recipe|
  suite = File.basename(recipe, '.rb')
  named_run_list suite, "test::#{suite}"
end

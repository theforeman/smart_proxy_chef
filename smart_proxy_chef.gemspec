# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smart_proxy_chef_plugin/version'

Gem::Specification.new do |gem|
  gem.name          = "smart_proxy_chef"
  gem.version       = ChefPlugin::VERSION
  gem.authors       = ['Marek Hulan']
  gem.email         = ['mhulan@redhat.com']
  gem.homepage      = "https://github.com/theforeman/smart_proxy_chef"
  gem.summary       = %q{Chef support for Foreman Smart-Proxy}
  gem.description   = <<-EOS
    Chef support for Foreman Smart-Proxy
  EOS

  gem.files         = Dir['{bundler.d,lib,settings.d}/**/*', 'LICENSE', 'Gemfile']
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.license = 'GPLv3'

  gem.add_development_dependency "bundler", "~> 1.7"
  gem.add_development_dependency('test-unit', '~> 2')
  gem.add_development_dependency('mocha', '~> 1')
  gem.add_development_dependency('webmock', '~> 1')
  gem.add_development_dependency('rack-test', '~> 0')
  gem.add_development_dependency('rake', '~> 10')

  gem.add_runtime_dependency('chef-api')
end


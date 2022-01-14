# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-drycc_output"
  gem.version       = "0.1.0"
  gem.authors       = ["engineering@drycc"]
  gem.email         = ["engineering@drycc.com"]
  gem.description   = %q{Fluentd output plugin for sending data to Drycc Components }
  gem.summary       = %q{Fluentd output plugin for sending data to Drycc Components}
  gem.homepage      = "https://github.com/drycc/fluentd"
  gem.license       = "ASL2"

  gem.files         = Dir.glob("{lib}/**/*") + %w(LICENSE README.md)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '>= 2.0.0'

  gem.add_runtime_dependency "fluentd"
  gem.add_runtime_dependency "fluent-mixin-plaintextformatter"
  gem.add_runtime_dependency "fluent-mixin-config-placeholders"
  gem.add_runtime_dependency "fluent-mixin-rewrite-tag-name"
  gem.add_runtime_dependency "redis"

  gem.add_development_dependency "bundler"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "test-unit"

end

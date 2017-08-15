Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-delay-inspector"
  gem.version       = "0.1.0"
  gem.authors       = ["TAGOMORI Satoshi"]
  gem.email         = ["tagomoris@gmail.com"]
  gem.summary       = %q{Fluentd plugin to inspect diff of real-time and log-time}
  gem.description   = %q{Inspect delay of log, and emit it, or inject it into message itself with specified attribute name}
  gem.homepage      = "https://github.com/tagomoris/fluent-plugin-delay-inspector"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
  gem.add_development_dependency "test-unit", "~> 3.2.0"
  gem.add_runtime_dependency "fluentd"
end

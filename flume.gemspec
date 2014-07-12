# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flume/version'

Gem::Specification.new do |spec|
  spec.name          = "flume"
  spec.version       = Flume::VERSION
  spec.authors       = ["Casey O'Hara"]
  spec.email         = ["casey.ohara@me.com"]
  spec.summary       = "Redis logger"
  spec.description   = "A Redis logger for Ruby/Rails"
  spec.homepage      = "https://github.com/caseyohara/flume"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "redis"
  spec.add_dependency "laissez", "~> 0.0.2"
  spec.add_dependency "thor", "~> 0.19.1"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "mock_redis", "~> 0.13.2"
  spec.add_development_dependency "timecop", "~> 0.7.1"
end


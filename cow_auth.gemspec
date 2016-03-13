# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cow_auth/version'

Gem::Specification.new do |spec|
  spec.name          = 'cow_auth'
  spec.version       = CowAuth::VERSION
  spec.authors       = ['Mickey Cowden']
  spec.email         = ['mickey@vt.edu']

  spec.summary       = 'Summary'
  spec.description   = 'Description'
  spec.homepage      = 'https://github.com/mickey13/cow_auth'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  # spec.add_runtime_dependency 'activesupport', '5.0.0.beta3'
  # spec.add_runtime_dependency 'scrypt', '~> 2.1'
  # spec.add_runtime_dependency 'redis', '~> 3.2'
end

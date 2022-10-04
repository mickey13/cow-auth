require_relative 'lib/cow_auth/version'

Gem::Specification.new do |spec|
  spec.name = 'cow_auth'
  spec.version = CowAuth::VERSION
  spec.authors = ['Mickey Cowden']
  spec.email = ['mickey@cowden.tech']

  spec.summary = 'Authentication gem'
  spec.description = 'The goal of this gem is to provide token-based authentication for Rails (or Rails-like) web applications.'
  spec.homepage = 'https://github.com/mickey13/cow-auth'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '~> 7.0'
  spec.add_dependency 'scrypt', '~> 3.0'
end

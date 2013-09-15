# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'igist/version'

Gem::Specification.new do |spec|
  spec.name          = "igist"
  spec.version       = IGist::VERSION
  spec.authors       = ["Yu Wang"]
  spec.email         = ["wangyuhere@gmail.com"]
  spec.description   = %q{IGist is a command line tool used to search your gists and starred gists by keyword of gist description.}
  spec.summary       = %q{Search your gists and starred gists by keyword of gist description}
  spec.homepage      = "https://github.com/wangyuhere/igist"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end

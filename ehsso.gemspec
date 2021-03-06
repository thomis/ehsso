# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ehsso/version'

Gem::Specification.new do |spec|
  spec.name          = "ehsso"
  spec.version       = Ehsso::VERSION
  spec.date          = "2017-06-14"
  spec.authors       = ["Thomas Steiner"]
  spec.email         = ["thomas.steiner@ikey.ch"]

  spec.summary       = %q{EH Single Sign On}
  spec.description   = %q{EH Single Sign On}
  spec.homepage      = "http://github.com/thomis/ehsso"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_development_dependency "rails", "~> 5.1"

  spec.add_runtime_dependency("typhoeus", "~> 1.3")
end

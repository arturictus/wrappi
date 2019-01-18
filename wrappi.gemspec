# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wrappi/version'

Gem::Specification.new do |spec|
  spec.name          = "wrappi"
  spec.version       = Wrappi::VERSION
  spec.authors       = ["Artur Pañach"]
  spec.email         = ["arturictus@gmail.com"]

  spec.summary       = %q{Framework to create HTTP API clients}
  spec.description   = %q{Framework to create HTTP API clients abstracting the best practices and improving readability to your code.}
  spec.homepage      = "https://github.com/arturictus/wrappi"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "sinatra"
  spec.add_dependency 'http', "~> 2.2"
  spec.add_dependency 'fusu', "~> 0.2.1"
  spec.add_dependency 'miller', "~> 0.1.1"
end

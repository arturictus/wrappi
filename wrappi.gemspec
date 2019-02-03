# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wrappi/version'

Gem::Specification.new do |spec|
  spec.name          = "wrappi"
  spec.version       = Wrappi::VERSION
  spec.authors       = ["Artur Pañach"]
  spec.email         = ["arturictus@gmail.com"]

  spec.summary       = %q{Making APIs fun again!}
  spec.description   = %q{Wrappi is a Framework to create API clients.
The intention is to bring the best practices and standardize how API clients behave.
It allows to create API clients in a declarative way improving readability and unifying the behavior.
It abstracts complex operations like caching, retries, background request and error handling.

Enjoy!}
  spec.homepage      = "https://github.com/arturictus/wrappi"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "sinatra"
  spec.add_dependency 'http', "~> 2.2"
  spec.add_dependency 'fusu', "~> 0.2.1"
  spec.add_dependency 'miller', "~> 0.1.1"
  spec.add_dependency 'retryable'
end

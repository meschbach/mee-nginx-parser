# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mee/nginx/parser/version'

Gem::Specification.new do |spec|
  spec.name          = "mee-nginx-parser"
  spec.version       = MEE::Nginx::Parser::VERSION
  spec.authors       = ["Mark Eschbach"]
  spec.email         = ["meschbach@gmail.com"]

  spec.summary       = %q{NginX configuration parser}
  spec.description   = %q{Parses an Nginx fragment into a data structure}
  spec.homepage      = "https://github.com/meschbach/mee-nginx-parser"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end

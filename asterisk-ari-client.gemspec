# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'asterisk/ari/client/version'

Gem::Specification.new do |spec|
  spec.name          = "asterisk-ari-client"
  spec.version       = Asterisk::Ari::Client::VERSION
  spec.authors       = ["Jan Svoboda"]
  spec.email         = ["jan@mluv.cz"]
  spec.summary       = %q{Ruby client library for the Asterisk REST Interface (ARI).}
  spec.description   = %q{Ruby client library for the Asterisk REST Interface (ARI).}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_development_dependency "minitest", "~> 5.4.2"
  spec.add_development_dependency "vcr", "~> 2.9.3"
  spec.add_development_dependency "webmock", "~> 1.19.0"

  spec.add_development_dependency "active_support", "~> 4.1.6"

  spec.add_dependency "websocket-client-simple", "~> 0.2.0"
  spec.add_dependency "event_emitter", "~> 0.2.5"
end

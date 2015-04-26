# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yaml_record/version'

Gem::Specification.new do |spec|
  spec.name          = "yaml_record"
  spec.version       = YamlRecord::VERSION
  spec.authors       = ["Nico Taing", "Nathan Esquenazi"]
  spec.email         = ["nico@gomiso.com"]
  spec.summary       = %q{YAML file persistence engine}
  spec.description   = %q{Use YAML for persisted data with ActiveModel interface}
  spec.homepage      = "https://github.com/nico-taing/yaml_record"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'shoulda', '~> 3.5.0'
end

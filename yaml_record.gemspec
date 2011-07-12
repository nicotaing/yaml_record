# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "yaml_record/version"

Gem::Specification.new do |s|
  s.name        = "yaml_record"
  s.version     = YamlRecord::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nico Taing", "Nathan Esquenazi"]
  s.email       = ["nico@gomiso.com"]
  s.homepage    = "https://github.com/nico-taing/yaml_record"
  s.summary     = %q{YAML file persistence engine}
  s.description = %q{Use YAML for persisted data with ActiveModel interface}

  s.rubyforge_project = "yaml_record"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency 'activesupport', '~> 2.3.11'
  s.add_development_dependency 'rake', '~> 0.9.2'
  s.add_development_dependency 'shoulda'
end

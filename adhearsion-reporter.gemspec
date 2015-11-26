# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "adhearsion/reporter/version"

Gem::Specification.new do |s|
  s.name        = "adhearsion-reporter"
  s.version     = Adhearsion::Reporter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben Klang"]
  s.email       = %w{bklang@mojolingo.com}
  s.homepage    = "http://github.com/adhearsion/adhearsion-reporter"
  s.summary     = %q{Report Adhearsion application deployments and exceptions}
  s.description = <<EOF
Report Adhearsion application exceptions and deployments to:

Airbrake
Errbit
This Adhearsion plugin requires Adhearsion 2.0 or later. For Adhearsion 1.0 try the previous version of this gem ahn_hoptoad
EOF
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "adhearsion", ["~> 2.0"]
  s.add_runtime_dependency "toadhopper", [">= 1.3.0"]
  s.add_runtime_dependency "newrelic_rpm", ["~> 3.6"]
  s.add_runtime_dependency "pony", ["~> 1.10"]
  s.add_runtime_dependency "sentry-raven", ["~> 0.15.0"]

  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'timecop'
end

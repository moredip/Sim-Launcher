# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sim_launcher/version"

Gem::Specification.new do |s|
  s.name        = "sim_launcher"
  s.version     = SimLauncher::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Pete Hodgson"]
  s.email       = ["rubygems@thepete.net"]
  s.homepage    = "http://rubygems.org/gems/sim_launcher"
  s.summary     = %q{tiny HTTP server to launch an app in the iOS simulator}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.post_install_message = <<-EOS

  ****************************************************************************************
  * sim_launcher expects the ios-sim binary in your $PATH. Install using e.g. Homebrew:  *
  *                                                                                      *
  *     brew install ios-sim                                                             *
  *                                                                                      *
  ****************************************************************************************

  EOS

  s.add_dependency "sinatra"

  s.add_development_dependency("rspec", [">=2.14.1"]) 
end

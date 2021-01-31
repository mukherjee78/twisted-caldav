# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require File.expand_path("../lib/twisted-caldav/version", __FILE__)

Gem::Specification.new do |s|
  s.name = "twisted-caldav"
  s.version = TwistedCaldav::VERSION
  s.summary = "Ruby calender server client"
  s.description = "Ruby client for searching, creating, editing calendar and tasks. Tested with ubuntu based calendar server installation."

  s.required_ruby_version = ">= 1.9.3"

  s.license = "MIT"

  s.homepage = %q{https://github.com/siddhartham/twisted-caldav}
  s.authors = [%q{Siddhartha Mukherjee}]
  s.email = [%q{mukherjee.siddhartha@gmail.com}]
  s.add_runtime_dependency "icalendar", "~> 2.x"
  s.add_runtime_dependency "uuid", "~> 2.x"
  s.add_runtime_dependency "net-http-digest_auth", "~> 1.x"
  s.add_runtime_dependency "builder", "~> 3.x"
  s.add_runtime_dependency "rspec", "~> 3.x"
  s.add_runtime_dependency "fakeweb", "~> 1.x"
  s.add_dependency "rake", "~> 13.0"

  s.add_development_dependency "bundler", "~> 2.0"

  s.description = <<-DESC
  Ruby client for searching, creating, editing calendar and tasks. Tested with ubuntu based calendar server installation.
DESC

  s.files = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end

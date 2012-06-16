# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "html_massage/version"

Gem::Specification.new do |s|
  s.name        = "html_massage"
  s.version     = HtmlMassager::VERSION
  s.authors     = ["Harlan T Wood"]
  s.email       = ["harlan@thegoldensun.com"]
  s.homepage    = "https://github.com/harlantwood/html_massage"
  s.summary     = %{Massages HTML how you want to.}
  s.description = %{Massages HTML how you want to: sanitize tags, remove headers and footers, convert to plain text.}

  s.rubyforge_project = "html_massage"

  s.add_dependency('nokogiri', ">= 1.4.4")
  s.add_dependency('sanitize', ">= 2.0.0")

  s.add_development_dependency('rspec', "~> 2.5.0")

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'html_massage/version'

Gem::Specification.new do |gem|
  gem.name          = "html_massage"
  gem.version       = HtmlMassager::VERSION
  gem.authors       = ["Harlan T Wood"]
  gem.email         = ["code@harlantwood.net"]
  gem.homepage      = "https://github.com/harlantwood/html_massage"
  gem.summary       = %{Massages HTML how you want to.}
  gem.description   = %{Massages HTML how you want to: sanitize tags, remove headers and footers; output to html, markdown, or plain text.}
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '>= 1.9.2'

  gem.add_dependency "nokogiri", "~> 1.6"
  gem.add_dependency "sanitize", "~> 3.0"
  gem.add_dependency "thor", "~> 0"
  gem.add_dependency "rest-client", "~> 1.7"
  gem.add_dependency "reverse_markdown", "~> 0.6"
  gem.add_dependency "charlock_holmes", "~> 0.7"

  gem.add_development_dependency "rspec", "~> 2.5"
end


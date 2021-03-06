# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'parcels/version'

Gem::Specification.new do |spec|
  spec.name          = "parcels"
  spec.version       = Parcels::VERSION
  spec.authors       = ["Andrew Geweke"]
  spec.email         = ["andrew@geweke.org"]
  spec.summary       = %q{Views are HTML...and CSS, and Javascript. Together at last!}
  spec.description   = %q{Allows you to package the CSS and Javascript for your view together with that view, creating self-contained parcels of view code that seamlessly work together. When used with Fortitude, automatically scopes your CSS, too. No more dueling CSS rules!}
  spec.homepage      = "https://github.com/ageweke/parcels"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  if RUBY_VERSION =~ /^1\.8\./
    spec.add_dependency "activesupport", "< 4.0.0"
  else
    spec.add_dependency "activesupport"
  end

  if (ENV['PARCELS_SPECS_SPROCKETS_VERSION'] || '').strip.length > 0
    spec.add_dependency "sprockets", "= #{ENV['PARCELS_SPECS_SPROCKETS_VERSION']}"
  else
    spec.add_dependency "sprockets", "< 3.0"
  end

  spec.add_dependency "sass"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "tilt", ">= 1.2"

  if RUBY_VERSION =~ /^1\.8\./
    spec.add_development_dependency "nokogiri", "< 1.6.0"
  else
    spec.add_development_dependency "nokogiri"
  end

  spec.add_development_dependency "oop_rails_server", "~> 0", ">= 0.0.5"
  spec.add_development_dependency "css_parser"
  spec.add_development_dependency "fortitude", ">= 0.9.2"
end

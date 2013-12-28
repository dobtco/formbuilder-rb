$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "formbuilder/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "formbuilder-rb"
  s.version     = Formbuilder::VERSION
  s.authors     = ["Adam Becker"]
  s.email       = ["adam@dobt.co"]
  s.homepage    = "https://github.com/dobtco/formbuilder-rb"
  s.summary     = "Build and save custom forms."
  s.description = "This is a Rails Engine for https://github.com/dobtco/formbuilder."
  s.license     = "MIT"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {features,spec}/*`.split("\n")

  s.add_dependency "rails", ">= 4.0.0"

  s.add_dependency 'carrierwave'
  s.add_dependency 'geocoder'
  s.add_dependency 'pg'
  s.add_dependency 'rmagick'

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'terminal-notifier-guard'
  s.add_development_dependency 'thin'
  s.add_development_dependency 'coveralls'

end

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

  s.add_dependency "rails", '~> 4.0', '>= 4.0.0'

  s.add_dependency 'carrierwave', '~> 0.10', '>= 0.10.0'
  s.add_dependency 'erector-rails4', '~> 0.1', '>= 0.1.0'
  s.add_dependency 'geocoder', '~> 1.1', '>= 1.1.9'
  s.add_dependency 'pg', '~> 0.17', '>= 0.17.1'
  s.add_dependency 'rinku', '~> 1.7', '>= 1.7.3'
  s.add_dependency 'rmagick', '~> 2.13', '>= 2.13.2'

  s.add_development_dependency 'capybara', '~> 2.2', '>= 2.2.1'
  s.add_development_dependency 'database_cleaner', '~> 1.2', '>= 1.2.0'
  s.add_development_dependency 'factory_girl_rails', '~> 4.4', '>= 4.4.1'
  s.add_development_dependency 'guard-rspec', '~> 4.2', '>= 4.2.8'
  s.add_development_dependency 'launchy', '~> 2.4', '>= 2.4.2'
  s.add_development_dependency 'rspec-rails', '~> 2.14', '>= 2.14.1'
  s.add_development_dependency 'spring', '~> 1.1', '>= 1.1.2'
  s.add_development_dependency 'spring-commands-rspec', '~> 1.0', '>= 1.0.1'
  s.add_development_dependency 'terminal-notifier-guard', '~> 1.5', '>= 1.5.3'
  s.add_development_dependency 'thin', '~> 1.6', '>= 1.6.2'
  s.add_development_dependency 'coveralls', '~> 0.7', '>= 0.7.0'

end

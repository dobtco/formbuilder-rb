$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "formbuilder/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "formbuilder"
  s.version     = Formbuilder::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Formbuilder."
  s.description = "TODO: Description of Formbuilder."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"

  s.add_dependency 'carrierwave'
  s.add_dependency 'pg'
  s.add_dependency 'rmagick'

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'terminal-notifier-guard'
  s.add_development_dependency 'thin'

end

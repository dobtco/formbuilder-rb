ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'formbuilder'
require 'factory_girl_rails'

Rails.backtrace_cleaner.remove_silencers!

require 'rspec/rails'
require 'capybara/rspec'

  Dir[Rails.root.join("../../spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.order = "random"
end

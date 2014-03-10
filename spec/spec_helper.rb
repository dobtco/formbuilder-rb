require 'database_cleaner'
require 'coveralls'
Coveralls.wear!

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter
]

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

class BaseUploader < CarrierWave::Uploader::Base

  @fog_public = false

  def store_dir
    digest = Digest::SHA2.hexdigest("#{model.class.to_s.underscore}-#{mounted_as}-#{model.id.to_s}").first(32)
    "uploads/#{digest}"
  end

  def raw_filename
    @model.read_attribute(:upload)
  end

end

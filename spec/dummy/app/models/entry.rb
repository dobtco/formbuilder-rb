class Entry < ActiveRecord::Base

  include Formbuilder::Entry

  attr_accessor :form

end

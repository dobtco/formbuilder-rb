class Entry < ActiveRecord::Base

  include Formbuilder::Entry

  belongs_to :form, class_name: 'Formbuilder::Form'

end

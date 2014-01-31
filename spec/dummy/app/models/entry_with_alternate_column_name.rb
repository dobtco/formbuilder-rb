class EntryWithAlternateColumnName < ActiveRecord::Base

  include Formbuilder::Entry

  belongs_to :form, class_name: 'Formbuilder::Form'

  after_initialize do
    @responses_column = 'responses_alt'
  end

end

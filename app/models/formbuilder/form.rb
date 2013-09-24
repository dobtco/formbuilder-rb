module Formbuilder
  class Form < ActiveRecord::Base

    has_many :response_fields, dependent: :destroy
    belongs_to :formable, polymorphic: true

    def input_fields
      response_fields.reject { |rf| !rf.input_field }
    end

  end
end

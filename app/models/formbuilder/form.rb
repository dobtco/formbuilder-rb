module Formbuilder
  class Form < ActiveRecord::Base

    has_many :response_fields, dependent: :destroy
    belongs_to :formable, polymorphic: true

    def input_fields
      response_fields.reject { |rf| !rf.input_field }
    end

    def response_fields_json
      self.response_fields.to_json(methods: [:field_type, :cid])
    end

  end
end

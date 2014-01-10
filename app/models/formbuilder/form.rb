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

    def copy_response_fields!(other_form)
      other_form.response_fields.each_with_index do |response_field, i|
        self.response_fields.create(
          label: response_field.label,
          type: response_field.type,
          field_options: response_field.field_options,
          sort_order: response_field.sort_order,
          required: response_field.required,
          blind: response_field.blind,
          admin_only: response_field.admin_only
        )
      end
    end


  end
end

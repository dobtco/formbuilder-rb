module Formbuilder
  class ResponseFieldText < ResponseField

    include ActionView::Helpers::TagHelper

    after_initialize -> {
      @field_type = 'text'
    }

    def render_input(value, opts = {})
      tag(:input, type: 'text', name: "response_fields[#{self.id}]", class: "rf-size-#{self[:field_options]['size']}",
          data: self.length_validations, value: value)
    end

  end
end

module Formbuilder
  class ResponseFieldNumber < ResponseField

    include ActionView::Helpers::TagHelper

    after_initialize -> {
      @sort_as_numeric = true
    }

    def render_input(value, opts = {})
      str = tag(:input, type: 'text', name: "response_fields[#{self.id}]",
                class: "rf-size-#{self[:field_options]['size']}", value: value)

      if (units = self[:field_options]['units'].presence)
        str += "<span class='units'>#{units}</span>".html_safe
      end

      str
    end

    def render_entry(value, opts = {})
      value
    end

    def validate_response(value)
      unless (Float(value) rescue nil)
        "isn't a valid number."
      end
    end

  end
end

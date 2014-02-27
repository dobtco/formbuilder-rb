module Formbuilder
  class ResponseFieldPageBreak < ResponseField

    after_initialize -> {
      @input_field = false
      @field_type = 'page_break'
    }

    def render_input(value, opts = {})
    end

  end
end

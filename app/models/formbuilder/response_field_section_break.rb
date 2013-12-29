module Formbuilder
  class ResponseFieldSectionBreak < ResponseField

    after_initialize -> {
      @input_field = false
      @field_type = 'section_break'
      @search_type = 'section_break'
    }

    def render_input(value, opts = {})
      """
        <label class='section-name'>#{self[:label]}</label>
        <p>#{self[:field_options]['description']}</p>
      """
    end

  end
end

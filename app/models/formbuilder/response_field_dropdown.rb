module Formbuilder
  class ResponseFieldDropdown < ResponseField

    after_initialize -> {
      @options_field = true
      @field_type = 'dropdown'
      @search_type = 'one_option'
    }

    def render_input(value, opts = {})
      options = ""
      options += "<option></option>" if self[:field_options]['include_blank_option']

      Array(self[:field_options]['options']).each_with_index do |option, i|
        selected = (value == option["label"]) || (value.blank? && option["checked"])
        options += "<option value='#{option["label"]}' #{selected ? 'selected' : ''}>#{option['label']}</option>"
      end

      """
        <select name='response_fields[#{self[:id]}]' id='response_fields_#{self[:id]}'>
          #{options}
        </select>
      """
    end

    def render_entry(value, opts = {})
      value
    end

  end
end

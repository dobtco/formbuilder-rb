module Formbuilder
  class ResponseFieldRadio < ResponseField

    after_initialize -> {
      @options_field = true
      @field_type = 'radio'
    }

    def render_input(value, opts = {})
      value ||= {}

      str = (self[:field_options]["options"] || []).each_with_index.map do |option, i|

        checked = (value == option["label"]) || (value.blank? && option["checked"])

        """
          <label class='fb-option'>
            <input type='radio' name='response_fields[#{self[:id]}]' #{checked ? 'checked' : ''} value='#{option['label']}' />
            #{option['label']}
          </label>
        """
      end.join('')

      if self[:field_options]['include_other_option']
        str += """
          <div class='other-option'>
            <label class='fb-option'>
              <input type='radio' name='response_fields[#{self[:id]}]' #{value == 'Other' ? 'checked' : ''} value='Other' />
              Other
            </label>

            <input type='text' name='response_fields[#{self[:id]}_other]'
                               value='#{opts.try(:[], :entry).try(:responses).try(:[], "#{self[:id]}_other")}' />
          </div>
        """
      end

      str
    end

    def render_entry(value, opts = {})
      str = value

      if (other = opts.try(:[], :entry).try(:responses).try(:[], "#{self.id}_other"))
        str += " (#{other})"
      end

      str
    end

  end
end

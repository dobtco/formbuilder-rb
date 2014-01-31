module Formbuilder
  class ResponseFieldRadio < ResponseField

    after_initialize -> {
      @options_field = true
      @field_type = 'radio'
      @search_type = 'one_option'
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
          <div class='fb-option'>
            <label>
              <input type='radio' name='response_fields[#{self[:id]}]' #{value == 'Other' ? 'checked' : ''} value='Other' />
              Other
            </label>

            <input type='text' name='response_fields[#{self[:id]}_other]'
                               value='#{opts.try(:[], :entry).try(:get_responses).try(:[], "#{self[:id]}_other")}' />
          </div>
        """
      end

      str
    end

    def render_entry(value, opts = {})
      str = value

      if (other = opts.try(:[], :entry).try(:get_responses).try(:[], "#{self.id}_other"))
        str += " (#{other})"
      end

      str
    end

    def transform_raw_value(raw_value, entry, opts = {})
      entry.get_responses["#{self.id}_other"] = (raw_value == 'Other') ?
                                                  opts[:response_field_params]["#{self.id}_other"] :
                                                  nil

      raw_value
    end

  end
end

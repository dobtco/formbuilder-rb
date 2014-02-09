module Formbuilder
  class ResponseFieldCheckboxes < ResponseField

    after_initialize -> {
      @serialized = true
      @options_field = true
      @field_type = 'checkboxes'
      @search_type = 'multiple_options'
    }

    def render_input(value, opts = {})
      value ||= {}

      str = (self[:field_options]["options"] || []).each_with_index.map do |option, i|
        checked = value.present? ? value[option['label']] : (option['checked'] == 'true')

        """
          <label class='fb-option'>
            <input type='checkbox' name='response_fields[#{self[:id]}][#{i}]' #{checked ? 'checked' : ''} value='on' />
            #{option['label']}
          </label>
        """
      end.join('')

      if self[:field_options]['include_other_option']
        str += """
          <div class='fb-option'>
            <label>
              <input type='checkbox' name='response_fields[#{self[:id]}][other_checkbox]' #{value['Other'] ? 'checked' : ''} value='on' />
              Other
            </label>

            <input type='text' name='response_fields[#{self[:id]}][other]' value='#{value['Other']}' />
          </div>
        """
      end

      str
    end

    def render_entry(value, opts = {})
      """
        <table class='response-table'>
          <thead>
            <tr>
              <th class='key'>Key</th>
              <th class='response'>Response</th>
            </tr>
          </thead>
          <tbody>
      """ +

      (value || {}).map do |k, v|
        """
          <tr class='#{v ? 'true' : 'false'}'>
            <td>#{k}</td>
            <td class='response'>#{v ? (k == 'Other' ? v : '<span class="icon-ok"></span>') : ''}</td>
          </tr>
        """
      end.join('') +

      """
          </tbody>
        </table>
      """
    end

    def render_entry_text(value, opts = {})
      (value || {}).map do |k, v|
        "#{k}: #{v ? (k == 'Other' ? v : 'y') : 'n'}"
      end.join("\n")
    end

    def sortable_value(value)
      nil # see :normalize_response for override
    end

    def normalize_response(value, all_responses)
      options_array.each do |option_label|
        all_responses["#{self.id}_sortable_values_#{option_label}"] = value[option_label]
      end
    end

    def transform_raw_value(raw_value, entry, opts = {})
      raw_value ||= {}

      {}.tap do |h|
        options_array.each_with_index do |label, index|
          h[label] = raw_value[index.to_s] == "on"
        end

        if raw_value['other_checkbox'] == 'on'
          entry.get_responses["#{self.id}_other"] = true
          h['Other'] = raw_value['other']
        end

        if h.find { |_, v| v }.present?
          entry.get_responses["#{self.id}_present"] = true
        else
          entry.get_responses.delete("#{self.id}_present")
        end
      end
    end

  end
end

module Formbuilder
  class ResponseFieldCheckboxes < ResponseField

    after_initialize -> {
      @serialized = true
      @options_field = true
      @field_type = 'checkboxes'
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

  end
end

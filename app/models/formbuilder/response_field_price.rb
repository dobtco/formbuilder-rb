module Formbuilder
  class ResponseFieldPrice < ResponseField

    after_initialize -> {
      @serialized = true
      @sort_as_numeric = true
      @field_type = 'price'
      @search_type = 'number'
    }

    def render_input(value, opts = {})
      value ||= {}

      str = """
        <div class='input-line'>
          <span class='above-line'>$</span>

          <span class='dollars'>
            <input type='text' name='response_fields[#{self[:id]}][dollars]' id='response_fields_#{self[:id]}' value='#{value['dollars']}' />
            <label>Dollars</label>
          </span>
      """

      unless self.field_options['disable_cents']
        str += """
          <span class='above-line'>.</span>

          <span class='cents'>
            <input type='text' name='response_fields[#{self[:id]}][cents]' value='#{value['cents']}' maxlength='2' />
            <label>Cents</label>
          </span>
        """
      end

      str += """
        </div>
      """

      str
    end

    def render_entry(value, opts = {})
      "$#{sprintf('%.2f', "#{value['dollars']}.#{value['cents']}".to_f)}"
    end

    # format: [dollars] [cents]
    # only one is required, and it must consist only of numbers
    def validate_response(value)
      if value.select { |k, v| k.in?(['dollars', 'cents']) && v.present? }
              .find { |k, v| (Float(v) rescue nil).nil? }
              .present?

        "isn't a valid price."
      end
    end

    def sortable_value(value)
      "#{value['dollars'] || '0'}.#{value['cents'] || '0'}".to_f
    end

  end
end

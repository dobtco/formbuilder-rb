module Formbuilder
  class ResponseFieldPrice < ResponseField

    after_initialize -> {
      @serialized = true
      @sort_as_numeric = true
    }

    def render_input(value, opts = {})
      """
        <div class='input-line'>
          <span class='above-line'>$</span>

          <span class='dollars'>
            <input type='text' name='response_fields[#{self[:id]}][dollars]' value='#{value['dollars']}' />
            <label>Dollars</label>
          </span>

          <span class='above-line'>.</span>

          <span class='cents'>
            <input type='text' name='response_fields[#{self[:id]}][cents]' value='#{value['cents']}' maxlength='2' />
            <label>Cents</label>
          </span>
        </div>
      """
    end

    def render_entry(value, opts = {})
      "$#{sprintf('%.2f', "#{value['dollars']}.#{value['cents']}".to_f)}"
    end

    # format: [dollars] [cents]
    # only one is required, and it must consist only of numbers
    def validate_response(value)
      value.select { |k, v| k.in?(['dollars', 'cents']) && v.present? }.each do |k, v|
        unless v =~ /^[0-9]+$/
          return "isn't a valid price."
        end
      end

      return nil
    end

  end
end

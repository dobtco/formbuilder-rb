module Formbuilder
  class ResponseFieldDate < ResponseField

    after_initialize -> {
      @serialized = true
      @sort_as_numeric = true
      @field_type = 'date'
      @search_type = 'date'
    }

    def render_input(value, opts = {})
      """
        <div class='input-line'>
          <span class='month'>
            <input type='text' name='response_fields[#{self[:id]}][month]' value='#{value['month']}' id='response_fields_#{self[:id]}' maxlength='2' />
            <label>MM</label>
          </span>

          <span class='above-line'>/</span>

          <span class='day'>
            <input type='text' name='response_fields[#{self[:id]}][day]' value='#{value['day']}' maxlength='2' />
            <label>DD</label>
          </span>

          <span class='above-line'>/</span>

          <span class='year'>
            <input type='text' name='response_fields[#{self[:id]}][year]' value='#{value['year']}' maxlength='4' />
            <label>YYYY</label>
          </span>
        </div>
      """
    end

    def render_entry(value, opts = {})
      "#{value['month']}/#{value['day']}/#{value['year']}"
    end

    def validate_response(value)
      if value['year'].to_i == 0 || !(DateTime.new(value['year'].to_i, value['month'].to_i, value['day'].to_i) rescue false)
        "isn't a valid date."
      end
    end

    def sortable_value(value)
      ['year', 'month', 'day'].each { |x| return 0 unless value[x].try(:present?) }
      DateTime.new(value['year'].to_i, value['month'].to_i, value['day'].to_i).to_i rescue 0
    end

  end
end

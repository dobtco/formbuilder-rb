module Formbuilder
  class ResponseFieldTime < ResponseField

    after_initialize -> {
      @serialized = true
      @sort_as_numeric = true
      @field_type = 'time'
      @search_type = 'time'
    }

    def render_input(value, opts = {})
      value ||= {}

      str = """
        <div class='input-line'>
          <span class='hours'>
            <input type='text' name='response_fields[#{self[:id]}][hours]' id='response_fields_#{self[:id]}' value='#{value['hours']}' maxlength='2' />
            <label>HH</label>
          </span>

          <span class='above-line'>:</span>

          <span class='minutes'>
            <input type='text' name='response_fields[#{self[:id]}][minutes]' value='#{value['minutes']}' maxlength='2' />
            <label>MM</label>
          </span>
      """


      if !self[:field_options]['disable_seconds']
        str += """
          <span class='above-line'>:</span>

          <span class='seconds'>
            <input type='text' name='response_fields[#{self[:id]}][seconds]' value='#{value['seconds']}' maxlength='2' />
            <label>SS</label>
          </span>
        """
      end

      str += """
          <span class='am_pm'>
            <select name='response_fields[#{self[:id]}][am_pm]'>
              <option value='AM' #{value['am_pm'] == "AM" ? 'selected' : ''}>AM</option>
              <option value='PM' #{value['am_pm'] == "PM" ? 'selected' : ''}>PM</option>
            </select>
          </span>
        </div>
      """

      str
    end

    def render_entry(value, opts = {})
      "#{value['hours']}:#{value['minutes']}#{if !value['seconds'].blank? then ':'+value['seconds'] end} #{value['am_pm']}"
    end

    def validate_response(value)
      if !value['hours'].to_i.between?(1, 12) || !value['minutes'].to_i.between?(0, 60) || !value['seconds'].to_i.between?(0, 60)
        "isn't a valid time."
      end
    end

    def sortable_value(value)
      hours = value['hours'].to_i
      hours += 12 if value['am_pm'] && value['am_pm'] == 'PM'
      (hours*60*60) + (value['minutes'].to_i * 60) + value['seconds'].to_i
    end

  end
end

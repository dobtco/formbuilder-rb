module Formbuilder
  class ResponseFieldTable < ResponseField

    include ActionView::Helpers::TagHelper
    include ActionView::Context

    after_initialize -> {
      @serialized = true
      @field_type = 'table'
      @search_type = 'table'
    }

    def columns_array
      Array(self[:field_options]['columns']).map { |column| column['label'] }
    end

    def render_input(value, opts = {})
      value ||= {}

      str = """
        <table class='border_all'>
          <thead>
            <tr>
      """

      columns_array.each_with_index do |column, i|
        str += """<th>#{column}</th>"""
      end

      str += """
            </tr>
          </thead>
          <tbody>
      """

      [self[:field_options]['minrows'].to_i, 1, number_of_saved_rows(value)].max.times do |i|
        str += """
          <tr>
        """

        columns_array.each_with_index do |column, j|
          preset_val = Hash(self.field_options['preset_values']).try(:[], column).try(:[], i)
          val = preset_val.presence || value[column].try(:[], i)

          str += """
            <td>
              <textarea name='response_fields[#{self[:id]}][#{j}][]'
                        #{preset_val.present? ? 'readonly' : ''}
                        data-col='#{j}'
                        data-row='#{i}'
                        rows='1'>#{val}</textarea>
            </td>
          """
        end

        str += """
          </tr>
        """
      end

      str += """
        <script class='template' type='text/template'>
          <tr>
      """

      columns_array.each_with_index do |_, j|
        str += """
          <td>
            <textarea name='response_fields[#{self[:id]}][#{j}][]' rows='1'></textarea>
          </td>
        """
      end

      str += """
          </tr>
        </script>
      """

      str += """
          </tbody>
      """

      if self[:field_options]['column_totals']
        str += """
          <tfoot>
        """

        columns_array.each_with_index do |column, j|
          str += """
            <td><span></span></td>
          """
        end

        str += """
          </tfoot>
        """
      end

      str += """
        </table>
      """

      str += """
        <div class='margin_th margin_bh'>
          <a class='uppercase add_another_row'><i class='icon-plus-sign'></i> Add another row</a>
        </div>
      """

      str
    end

    def render_entry(value, opts = {})
      value ||= {}

      str = """
        <table class='border_all'>
          <thead>
            <tr>
      """

      columns_array.each_with_index do |column, i|
        str += """<th>#{column}</th>"""
      end

      str += """
            </tr>
          </thead>
          <tbody>
      """

      number_of_saved_rows(value).times do |i|
        str += """
          <tr>
        """

        columns_array.each_with_index do |column, j|
          str += """
            <td>#{value[column].try(:[], i)}</td>
          """
        end

        str += """
          </tr>
        """
      end

      str += """
          </tbody>
      """

      if self[:field_options]['column_totals']
        str += """
          <tfoot>
        """

        columns_array.each_with_index do |column, j|
          total = opts.try(:[], :entry).try(:get_responses).try(:[], "#{self.id}_sum_#{column}")

          str += """
            <td><span>#{total.to_f > 0 ? total : ''}</span></td>
          """
        end

        str += """
          </tfoot>
        """
      end

      str += """
        </table>
      """

      str
    end

    def render_entry_text(value, opts = {})
      (value || {}).map do |k, v|
        "#{k}: " + Array(v).join(', ')
      end.join("; ")
    end

    def sortable_value(value)
      nil # see :normalize_response for override
    end

    def number_of_saved_rows(value)
      value.try(:first).try(:[], 1).try(:length) || 0
    end

    def normalize_response(value, all_responses)
      # Calculate sums and store in the hstore
      columns_array.each do |column|
        all_responses["#{self.id}_sum_#{column}"] = Array(value[column]).map do |x|
          x.gsub(/\$?,?/, '').to_f
        end.inject(:+)
      end
    end

    def transform_raw_value(raw_value, entry, opts = {})
      raw_value ||= {}

      {}.tap do |h|
        columns_array.each_with_index do |column, index|
          h[column] = raw_value[index.to_s]
        end

        # Iterate through each row, and remove ones without any values.
        i = Array(h.first[1]).length - 1
        while i >= 0
          unless h.find { |k, v| v[i].present? }
            h.each do |k, v|
              v.delete_at(i)
            end
          end

          i = i - 1
        end
      end
    end

  end
end

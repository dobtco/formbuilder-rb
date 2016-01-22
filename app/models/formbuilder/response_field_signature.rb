module Formbuilder
  class ResponseFieldSignature < ResponseField
    after_initialize -> {
      @input_field = false
      @field_type = 'signature'
    }

    def render_input(value, opts = {})
      str = """
        <label>#{self[:label]}</label>
      """

      if self[:field_options][:description].present?
        str += """<p>#{self[:field_options][:description]}</p>"""
      end

      str += """
        <canvas id='signature-#{self.id}'></canvas>
      """

      str
    end
  end
end

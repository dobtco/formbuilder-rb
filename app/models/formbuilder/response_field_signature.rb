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

      str += """
        <div id='signature-pad-#{self.id}' class='m-signature-pad'>
          <div class='m-signature-pad--body'>
            <canvas></canvas>
          </div>
          <div class='m-signature-pad--footer'>
            <div class='description'>#{self[:field_options][:description]}</div>
            <button type='button' class='button clear' data-action='clear'>Clear</button>
            <button type='button' class='button save' data-action='save'>Save</button>
          </div>
        </div>
      """

      str
    end
  end
end

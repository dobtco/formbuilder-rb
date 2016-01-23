module Formbuilder
  class ResponseFieldSignature < ResponseField
    after_initialize -> {
      @field_type = 'signature'
      @search_type = 'signature'
    }

    def render_input(value, opts = {})
      # str = """
      #   <label>#{self[:label]}</label>
      # """

      str = """
        <div id='signature-pad-#{self.id}' class='m-signature-pad'>
          <div class='m-signature-pad--body'>
            <canvas data-id='#{self.id}'></canvas>
          </div>
          <div class='m-signature-pad--footer'>
            <div class='description'>#{self[:field_options][:description]}</div>
            <button type='button' class='button clear' data-clear-id='#{self.id}' data-action='clear'>Clear</button>
            <button type='button' class='button save' data-save-id='#{self.id}' data-action='save'>Save</button>
          </div>
        </div>
      """

      str += """
        <input name='response_fields[#{self.id}]' type='hidden' value='' />
      """

      str
    end

    def render_entry(value, opts = {})
      "<img src='#{value}' />"
    end
  end
end

module Formbuilder
  class ResponseFieldBlockOfText < ResponseField

    after_initialize -> {
      @input_field = false
      @field_type = 'block_of_text'
    }

    def render_input(value, opts = {})
      """
        <div class='block-of-text block-of-text-size-#{self[:field_options]['size']}'>
          #{self[:label]}
        </div>
      """
    end

  end
end

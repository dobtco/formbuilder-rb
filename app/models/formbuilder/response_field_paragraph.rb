require 'rinku'

module Formbuilder
  class ResponseFieldParagraph < ResponseField

    include ActionView::Helpers::TagHelper
    include ActionView::Context

    after_initialize -> {
      @field_type = 'paragraph'
      @search_type = 'text'
    }

    def render_input(value, opts = {})
      content_tag(
        :textarea,
        name: "response_fields[#{self.id}]",
        id: "response_fields_#{self.id}",
        class: "rf-size-#{self[:field_options]['size']}",
        data: self.length_validations
      ) { value }
    end

    def render_entry(value, opts = {})
      if value.present?
        ActionController::Base.helpers.simple_format(Rinku.auto_link(value))
      else
        ''
      end
    end

    def render_entry_text(value, opts = {})
      value
    end

  end
end

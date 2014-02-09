module Formbuilder
  class ResponseFieldWebsite < ResponseField

    include ActionView::Helpers::TagHelper

    after_initialize -> {
      @field_type = 'website'
      @search_type = 'text'
    }

    def render_input(value, opts = {})
      tag(
        :input,
        type: 'text',
        name: "response_fields[#{self.id}]",
        id: "response_fields_#{self.id}",
        class: "rf-size-#{self[:field_options]['size']}",
        value: value,
        placeholder: 'http://'
      )
    end

    def render_entry(value, opts = {})
      "<a href='#{value}' target='_blank' rel='nofollow'>#{value}</a>"
    end

    def render_entry_text(value, opts = {})
      value
    end

    def validate_response(value)
      require 'uri'

      # add http if not present
      value = "http://#{value}" unless value[/^http:\/\//] || value[/^https:\/\//]

      if !(value =~ URI::regexp) # this doesn't really validate, since almost *anything* matches
        "isn't a valid URL."
      end
    end

    def normalize_response(value, all_responses)
      return if value.blank?

      unless value[/^http:\/\//] || value[/^https:\/\//]
        all_responses[self.id.to_s] = "http://#{value}"
      end
    end

    def sortable_value(value)
      value[0..20]
    end

  end
end

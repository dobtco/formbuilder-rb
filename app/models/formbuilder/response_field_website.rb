module Formbuilder
  class ResponseFieldWebsite < ResponseField

    include ActionView::Helpers::TagHelper

    after_initialize -> {
      @field_type = 'website'
    }

    def render_input(value, opts = {})
      tag(:input, type: 'text', name: "response_fields[#{self.id}]", class: "rf-size-#{self[:field_options]['size']}",
          value: value, placeholder: 'http://')
    end

    def render_entry(value, opts = {})
      "<a href='#{value}' target='_blank' rel='nofollow'>#{value}</a>"
    end

    def validate_response(value)
      require 'uri'

      # add http if not present
      value = "http://#{value}" unless value[/^http:\/\//] || value[/^https:\/\//]

      if !(value =~ URI::regexp) # this doesn't really validate, since almost *anything* matches
        "isn't a valid URL."
      end
    end

  end
end

module Formbuilder
  class EntryRenderer
    include ActionView::Context
    include ActionView::Helpers::TagHelper

    def initialize(entry, form, opts = {})
      @entry, @form = entry, form
      @options = opts # merge defaults?
    end

    def fields
      return_fields = @form.response_fields.reject { |rf| !rf.input_field }
      return_fields.reject! { |rf| rf.blind? } unless @options[:show_blind]
      return_fields
    end

    def to_html
      content_tag 'dl', class: 'entry-dl' do
        fields.map do |rf|
          """
            <dt>#{field_labels(rf)}</dt>
            <dd>
              #{field_value(rf) || no_value}
            </dd>
          """
        end.join('').html_safe
      end
    end

    def field_labels(rf)
      """
        #{rf.label}
        #{rf.blind? ? '<span class="label">Blind</span>' : ''}
        #{rf.admin_only? ? '<span class="label">Admin Only</span>' : ''}
      """
    end

    def no_value
      "<span class='no-response'>No response</span>"
    end

    def field_value(rf)
      value = @entry.response_value(rf)
      rf.render_entry(value, entry: @entry)
    end
  end
end

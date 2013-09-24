module Formbuilder
  class EntryTableRenderer < EntryRenderer
    # include ActionView::Context
    # include ActionView::Helpers::TagHelper

    # def initialize(entry, form, opts = {})
    #   @entry, @form = entry, form
    #   @options = opts # merge defaults?
    # end

    # def fields
    #   return_fields = @form.response_fields.reject { |rf| rf.non_input_field? }
    #   return_fields.reject! { |rf| rf.blind? } unless @options[:show_blind]
    #   return_fields
    # end

    def to_html
      content_tag 'dl', class: 'entry-dl' do
        fields.map do |rf|
          field_value(rf)
        end.join('').html_safe
      end
    end

    def field_value(rf)
      value = @entry.response_value(rf)
      rf.field_class.render_entry_for_table(rf, value, entry: @entry)
    end

    # def field_labels(rf)
    #   """
    #     #{rf.label}
    #     #{rf.blind? ? '<span class="label">Blind</span>' : ''}
    #     #{rf.admin_only? ? '<span class="label">Admin Only</span>' : ''}
    #   """
    # end

    # def no_value
    #   "<span class='no-response'>No response</span>"
    # end

    # def field_value(rf)
    #   value = @entry.response_value(rf)
    #   Formbuilder::Fields.const_get(rf.field_type.camelize + 'Field').render_entry(rf, value, entry: @entry)
    # end

    # def checkboxes_for_table
    #   (@response_field.field_options['options'] || []).map do |option|
    #     """
    #       <td data-column-id='#{@response_field.id}_sortable_values_#{option['label']}'>
    #         <i class='#{@value && @value[option['label']] ? 'icon-ok' : 'icon-remove'}'></i>
    #       </td>
    #     """
    #   end.join('')
    # end

  end
end

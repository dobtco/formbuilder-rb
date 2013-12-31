module Formbuilder
  module Views
    class Form < Erector::Widget

      needs :form,
            :entry,
            action: '',
            method: 'POST',
            show_blind: false,
            show_admin_only: false

      def content
        form_tag @action, method: @method, class: 'formbuilder-form', multipart: true do
          render_fields
          actions
        end
      end

      private
      def render_fields
        response_fields.each do |rf|
          widget Formbuilder::Views::FormField.new(response_field: rf, entry: @entry)
        end
      end

      def response_fields
        return_array = @form.response_fields
        return_array = return_array.reject { |rf| rf.blind? } unless @show_blind
        return_array = return_array.reject { |rf| rf.admin_only? } unless @show_admin_only
        return_array
      end

      def actions
        div(class: 'form-actions') {
          button.button.primary 'Submit'
        }
      end

    end
  end
end
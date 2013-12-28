module Formbuilder
  module Views
    class Form < Erector::Widget

      needs :form, :entry, action: '', method: 'POST'

      def content
        form_tag @action, method: @method, class: 'formbuilder-form', multipart: true do
          fields
          actions
        end
      end

      # @todo csrf

      def fields
        @form.response_fields.each do |rf|
          widget Formbuilder::Views::FormField.new(response_field: rf, entry: @entry)
        end
      end

      def actions
        div(class: 'form-actions') {
          button.button.primary 'Submit'
        }
      end

    end
  end
end
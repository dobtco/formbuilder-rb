module Formbuilder
  module Views
    class FormField < Erector::Widget

      needs :response_field, :entry

      def content
        @value = @entry.try(:response_value, @response_field)

        div(class: "fb-field-wrapper response-field-#{@response_field.field_type} #{@entry.try(:error_for, @response_field) && 'error'}") {
          render_label if @response_field.input_field
          rawtext @response_field.render_input(@value, entry: @entry)
          div.clear
          render_error if @response_field.input_field && @entry.error_for(@response_field)
          render_description if @response_field.input_field && @response_field[:field_options]["description"].present?
        }
      end

      private
      def render_label
        label(for: "response_fields_#{@response_field.id}") {
          text @response_field[:label]

          if @response_field.required?
            text ' '
            abbr('*', title: 'required')
          end
        }
      end

      def render_error
        span(class: "help-block validation-message-wrapper") {
          text @entry.error_for(@response_field)
        }
      end

      def render_description
        span(class: 'help-block') {
          text simple_format(@response_field[:field_options]["description"])
        }
      end

    end
  end
end

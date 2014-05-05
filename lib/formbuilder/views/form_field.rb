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
          render_min_max_lengths
          render_min_max
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

      def render_min_max_lengths
        return unless @response_field.input_field && @response_field.has_length_validations?

        div.min_max {
          if @response_field.minlength && @response_field.maxlength
            text "Between #{@response_field.minlength} and #{@response_field.maxlength} #{@response_field.min_max_length_units}."
          elsif @response_field.minlength
            text "More than #{@response_field.minlength} #{@response_field.min_max_length_units}."
          elsif @response_field.maxlength
            text "Less than #{@response_field.maxlength} #{@response_field.min_max_length_units}."
          end

          text ' Current count: '
          code.min_max_counter
          text " #{@response_field.min_max_length_units}."
        }
      end

      def render_min_max
        return unless @response_field.input_field && @response_field.min_max_validations.present?

        div.min_max {
          div.min_max_info {
            if @response_field.min && @response_field.max
              text "Between #{@response_field.min} and #{@response_field.max}."
            elsif @response_field.min
              text "More than #{@response_field.min}."
            elsif @response_field.max
              text "Less than #{@response_field.max}."
            end
          }
        }
      end

    end
  end
end

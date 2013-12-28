module Formbuilder
  class FormRenderer

    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::FormTagHelper
    include ActionView::Context

    def protect_against_forgery?; false; end;

    DEFAULT_OPTIONS = {
      action: '',
      method: 'POST'
    }

    def initialize(form, entry, options = {})
      @form, @entry = form, entry
      @options = self.class::DEFAULT_OPTIONS.merge(options)
    end

    def to_html
      form_tag @options[:action], method: @options[:method], class: 'formbuilder-form', multipart: true do
        hidden_fields +
        render_fields +
        render_actions
      end
    end

    def hidden_fields
      ''.html_safe
    end

    def render_fields
      @form.response_fields.map do |field|
        @field = field
        render_field
      end.join('').html_safe
    end

    def render_field
      value = @entry.try(:response_value, @field)

      """
        <div class='fb-field-wrapper response-field-#{@field.field_type} #{@entry.try(:error_for, @field) && 'error'}'>
          #{render_label}
          #{@field.render_input(value, entry: @entry)}
          <div class='cf'></div>
          #{render_error}
          #{render_description}
          #{render_length_validations}
          #{render_min_max_validations}
        </div>
      """
    end

    def render_label
      return unless @field.input_field

      """
        <label for='response_fields_#{@field.id}'>
          #{@field[:label]}
          #{render_label_required if @field.required?}
        </label>
      """
    end

    def render_label_required
      "<abbr title='required'>*</abbr>"
    end

    def render_error
      return unless @field.input_field
      return unless @entry.error_for(@field)
      "<span class='help-block validation-message-wrapper'>#{@entry.error_for(@field)}</span>"
    end

    def render_description
      return unless @field.input_field
      return if @field[:field_options]["description"].blank?
      "<span class='help-block'>#{simple_format(@field[:field_options]["description"])}</span>"
    end

    def render_length_validations
      return unless @field.input_field
      return unless !@field.has_length_validations?
    end

    def render_min_max_validations
      return unless @field.input_field
    end

    def render_actions
      """
        <div class='form-actions'>
          <button class='button primary'>Submit</button>
        </div>
      """.html_safe
    end
  end
end

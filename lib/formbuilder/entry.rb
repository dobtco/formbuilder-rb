module Formbuilder
  module Entry
    extend ActiveSupport::Concern

    included do
      attr_accessor :skip_validation, :only_validate_page

      before_validation :normalize_responses
      validates_with Formbuilder::EntryValidator
      before_save :calculate_responses_text, if: :responses_column_changed?

      scope :order_by_response_field_value, -> (response_field, direction) {
        if response_field.sort_as_numeric
          order("(responses -> '#{response_field.id}_sortable_value') ::numeric #{direction} NULLS LAST")
        else
          order("LOWER(responses -> '#{response_field.id}_sortable_value') #{direction} NULLS LAST")
        end
      }

      scope :order_by_response_field_checkbox_value, -> (response_field, option, direction) {
        order("(CASE WHEN (responses -> '#{response_field.id}_sortable_values_#{option}') = 'true' THEN
                  1
                ELSE
                  0
                END) #{direction}".squish)
      }

      scope :order_by_response_field_table_sum, -> (response_field, column, direction) {
        order("(responses -> '#{response_field.id}_sum_#{column}') ::numeric #{direction}")
      }
    end

    def valid_page?(x)
      self.valid?
      !self.errors_on_page?(x)
    end

    def first_page_with_errors
      if (i = pages_with_errors.find_index { |x| x == true })
        i + 1
      else
        nil
      end
    end

    def pages_with_errors
      form.response_fields_by_page.map do |page|
        page.find { |response_field| self.error_for(response_field).present? } ? true : false
      end
    end

    def errors_on_page?(x)
      pages_with_errors[x - 1] # 0-indexed
    end

    def responses_column
      @responses_column || 'responses'
    end

    def responses_column=(x)
      @responses_column = x
    end

    def get_responses
      send(responses_column)
    end

    def set_responses(x)
      send("#{responses_column}=", x)
    end

    def mark_responses_as_changed!
      send("#{responses_column}_will_change!")
    end

    def responses_column_changed?
      send("#{responses_column}_changed?")
    end

    def responses_column_was
      send("#{responses_column}_was")
    end

    def value_present?(response_field)
      value = self.response_value(response_field)

      # value isn't blank (ignore hashes)
      return true if (value && value.present? && !value.is_a?(Hash))

      # no options are available
      return true if (response_field.options_field && Array(response_field.field_options["options"]).empty?)

      # there is at least one value (for hashes)
      # reject select fields
      return true if (value.is_a?(Hash) && value.reject { |k, v| k.in? ['am_pm', 'country'] }.find { |k, v| v.present? })

      # otherwise, it's not present
      return false
    end

    def response_value(response_field)
      value = get_responses[response_field.id.to_s]

      if value
        response_field.serialized ? YAML::load(value) : value
      elsif !value && response_field.serialized && response_field.field_type != 'checkboxes'
        {}
      else # for checkboxes, we need to know the difference between no value and none selected
        nil
      end
    end

    def save_responses(response_field_params, response_fields, opts = {})
      set_responses({}) unless opts[:partial_update]
      response_field_params ||= {}

      response_fields.select { |rf| rf.input_field }.each do |response_field|
        self.save_response(response_field_params[response_field.id.to_s], response_field, response_field_params)
      end
    end

    def save_response(raw_value, response_field, response_field_params = {})
      value = response_field.transform_raw_value(raw_value, self, response_field_params: response_field_params)

      if value.present?
        get_responses["#{response_field.id}"] = response_field.serialized ? value.to_yaml : value
        get_responses["#{response_field.id}_sortable_value"] = response_field.sortable_value(value)
      else
        get_responses.delete("#{response_field.id}")
        get_responses.delete("#{response_field.id}_sortable_value")
      end

      mark_responses_as_changed!
    end

    def destroy_response(response_field)
      response_field.before_response_destroyed(self)
      id = response_field.id.to_s
      set_responses get_responses.reject { |k, v| k.in?([id, "#{id}_sortable_value"]) }
      mark_responses_as_changed!
    end

    def error_for(response_field)
      Array(self.errors.messages[:"#{responses_column}_#{response_field.id}"]).first
    end

    def calculate_responses_text
      return unless self.respond_to?(:"#{responses_column}_text=")
      self.send(:"#{responses_column}_text=", get_responses.select { |k, v| Integer(k) rescue nil }.values.join(' '))
    end

    # for manual use, maybe when migrating
    def calculate_sortable_values
      response_fieldable.input_fields.each do |response_field|
        if (x = response_value(response_field)).present?
          get_responses["#{response_field.id}_sortable_value"] = response_field.sortable_value(x)
        end
      end

      mark_responses_as_changed!
    end

    # Normalizations get run before validation.
    def normalize_responses
      return if form.blank?

      form.response_fields.each do |response_field|
        if (x = self.response_value(response_field))
          response_field.normalize_response(x, get_responses)
        end
      end

      mark_responses_as_changed!
    end

    # Audits get run explicitly.
    def audit_responses
      form.response_fields.each do |response_field|
        response_field.audit_response(self.response_value(response_field), get_responses)
      end

      mark_responses_as_changed!
    end

  end
end

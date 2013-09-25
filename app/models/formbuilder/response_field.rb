module Formbuilder
  class ResponseField < ActiveRecord::Base

    default_scope -> { order('sort_order') }

    # For backbone saving compatibility
    attr_accessor :cid

    # Does this field take an input?
    # (An example of a non-input field is a section break.)
    attr_accessor :input_field

    # Does this field have a preset list of options?
    attr_accessor :options_field

    # Do we need to serialize the response for this field?
    attr_accessor :serialized

    # Should we sort this field's responses as numeric values?
    attr_accessor :sort_as_numeric

    # Underscored name of this field
    attr_accessor :field_type

    after_initialize -> {
      @input_field = true
    }

    scope :not_blind, -> { where(blind: false) }
    scope :not_admin_only, -> { where(admin_only: false) }

    belongs_to :form

    serialize :field_options, Hash

    ALLOWED_PARAMS = [:key, :blind, :label, :field_options, :required, :admin_only]

    def required?
      field_options['required']
    end

    def length_validations(include_units = true)
      return_hash = {
        minlength: field_options[:minlength],
        maxlength: field_options[:maxlength]
      }

      return_hash[:min_max_length_units] = field_options[:min_max_length_units] if include_units

      return_hash.select { |k, v| v.present? }
    end

    def has_length_validations?
      length_validations(false).any?
    end

    def min_max_validations
      return_hash = {
        min: field_options[:min],
        max: field_options[:max]
      }

      return_hash.select { |k, v| v.present? }
    end

    def render_entry_for_table(value, opts = {})
      """
        <td data-column-id='#{self.id}'>
          #{render_entry(value, opts)}
        </td>
      """
    end

    def render_input(value, opts = {})
      raise 'Not implemented'
    end

    def render_entry(value, opts = {})
      value
    end

    def validate_response(value)
    end

  end
end

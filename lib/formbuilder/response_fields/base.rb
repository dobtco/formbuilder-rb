module Formbuilder
  module ResponseFields
    module Base
      extend ActiveSupport::Concern

      included do
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

        after_initialize -> {
          @input_field = true
        }

        scope :not_blind, -> { where(blind: false) }
        scope :not_admin_only, -> { where(admin_only: false) }

        belongs_to :form

        serialize :field_options, Hash

        ALLOWED_PARAMS = [:key, :blind, :label, :field_options, :required, :admin_only]
      end

      def field_type
        self.class.name.split('::').last.underscore
      end

      def required?
        field_options['required']
      end

      def length_validations(include_units = true)
        attrs = [:minlength, :maxlength]
        attrs.push(:min_max_length_units) if include_units
        pick(field_options, *attrs).select { |k, v| v.present? }
      end

      def has_length_validations?
        length_validations(false).any?
      end

      def min_max_validations
        pick(field_options, :min, :max).select { |k, v| v.present? }
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
end
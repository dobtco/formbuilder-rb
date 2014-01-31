module Formbuilder
  class EntryValidator < ActiveModel::Validator
    SHARED_VALIDATION_METHODS = [:min_max_length, :min_max, :integer_only]

    def validate(record)
      @record = record

      # I guess it's valid if there's no form?
      return if record.form.blank?

      # we can also skip validation by setting this flag
      return if record.skip_validation

      record.form.response_fields.not_admin_only.reject { |rf| !rf.input_field }.each do |response_field|
        @response_field = response_field
        @value = @record.response_value(@response_field)

        if @response_field.required? && !@record.value_present?(@response_field)
          add_error "can't be blank"
          next
        end

        if @record.value_present?(@response_field)
          # Field-specific validation
          add_error(@response_field.validate_response(@value))

          SHARED_VALIDATION_METHODS.each do |method_name|
            run_validation(method_name)
          end
        end
      end
    end

    private
    def add_error(msg)
      return unless msg.present?
      @record.errors["#{@record.responses_column}_#{@response_field.id}"] << msg
    end

    def run_validation(method_name)
      if (error_message = send(method_name))
        add_error(error_message)
      end
    end

    def min_max_length
      return unless @response_field.field_options["minlength"].present? ||
                    @response_field.field_options["maxlength"].present?

      if @response_field.field_options["min_max_length_units"] == 'words'
        min_max_length_words
      else
        min_max_length_characters
      end
    end

    def min_max_length_characters
      if @response_field.field_options["minlength"].present? && (@value.length < @response_field.field_options["minlength"].to_i)
        return "is too short. It should be #{@response_field.field_options["minlength"]} characters or more."
      end

      if @response_field.field_options["maxlength"].present? && (@value.length > @response_field.field_options["maxlength"].to_i)
        return "is too long. It should be #{@response_field.field_options["maxlength"]} characters or less."
      end
    end

    def min_max_length_words
      if @response_field.field_options["minlength"].present? && (@value.scan(/\w+/).count < @response_field.field_options["minlength"].to_i)
        return "is too short. It should be #{@response_field.field_options["minlength"]} words or more."
      end

      if @response_field.field_options["maxlength"].present? && (@value.scan(/\w+/).count > @response_field.field_options["maxlength"].to_i)
        return "is too long. It should be #{@response_field.field_options["maxlength"]} words or less."
      end
    end

    def min_max
      return unless @response_field.field_options["min"].present? ||
                    @response_field.field_options["max"].present?

      value_for_comparison = case @response_field.field_type
      when 'price'
       "#{@value['dollars'] || 0}.#{@value['cents'] || 0}".to_f
      else
        @value.to_f
      end

      if @response_field.field_options["min"].present? && (value_for_comparison < @response_field.field_options["min"].to_f)
        return "is too small. It should be #{@response_field.field_options["min"]} or more."
      end

      if @response_field.field_options["max"].present? && (value_for_comparison > @response_field.field_options["max"].to_f)
        return "is too large. It should be #{@response_field.field_options["max"]} or less."
      end
    end

    def integer_only
      if @response_field.field_options["integer_only"] && !(Integer(@value) rescue false)
        "only integers allowed."
      end
    end

  end
end

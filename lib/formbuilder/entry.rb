module Formbuilder
  module Entry
    extend ActiveSupport::Concern

    included do
      attr_accessor :old_responses
      attr_accessor :skip_validation

      before_validation :normalize_responses
      validates_with Formbuilder::EntryValidator
      before_save :calculate_responses_text, if: :responses_changed?

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
      value = responses && responses[response_field.id.to_s]

      if value
        response_field.serialized ? YAML::load(value) : value
      elsif !value && response_field.serialized && response_field.field_type != 'checkboxes'
        {}
      else # for checkboxes, we need to know the difference between no value and none selected
        nil
      end
    end

    def save_responses(response_field_params, response_fields)
      self.old_responses = self.responses.try(:clone) || {}
      self.responses = {}

      response_fields.reject { |rf| !rf.input_field }.each do |response_field|
        self.save_response(response_field_params.try(:[], response_field.id.to_s), response_field, response_field_params)
      end
    end

    def save_response(raw_value, response_field, response_field_params = {})
      value = case response_field.field_type
      when "checkboxes"
        # transform checkboxes into {label => on/off} pairs
        values = {}
        value_present = false

        (response_field[:field_options]["options"] || []).each_with_index do |option, index|
          label = response_field.field_options["options"][index]["label"]

          if raw_value && raw_value[index.to_s] == "on"
            value_present = true
            values[option["label"]] = true
          else
            values[option["label"]] = false
          end
        end

        if raw_value && raw_value['other_checkbox'] == 'on'
          responses["#{response_field.id}_other"] = true
          values['Other'] = raw_value['other']
          value_present = true
        else
          values.delete('Other')
        end

        if value_present
          responses["#{response_field.id}_present"] = true
        else
          responses.delete("#{response_field.id}_present")
        end

        values

      when "file"
        # if the file is already uploaded and we're not uploading another, be sure to keep it
        if raw_value.blank?
          old_responses.try(:[], response_field.id.to_s)
        else
          remove_entry_attachments(responses.try(:[], response_field.id.to_s))
          EntryAttachment.create(upload: raw_value).id
        end
      # when "filebucket"
      #   # if the file is already uploaded and we're not uploading another, be sure to keep it
      #   if raw_value.blank?
      #     old_responses.try(:[], response_field.id.to_s)
      #   else
      #     remove_entry_attachments(Array(responses.try(:[], response_field.id.to_s)))
      #     EntryAttachment.create(upload: raw_value).id
      #   end

      when "radio"
        # Save 'other' value
        responses["#{response_field.id}_other"] = raw_value == 'Other' ?
                                                    response_field_params["#{response_field.id}_other"] :
                                                    nil

        raw_value
      else
        raw_value
      end

      self.responses ||= {}

      if value.present?
        self.responses["#{response_field.id}"] = response_field.serialized ? value.to_yaml : value
        calculate_sortable_value(response_field, value)
      end

      self.responses_will_change!
    end

    def destroy_response(response_field)
      response_field.before_destroy(self)
      id = response_field.id.to_s
      self.responses = self.responses.reject { |k, v| k.in?([id, "#{id}_sortable_value"]) }
      self.responses_will_change!
    end

    def remove_entry_attachments(entry_attachment_ids)
      return unless entry_attachment_ids.present?

      entry_attachment_ids.to_s.split(',').each do |x|
        EntryAttachment.find_by(id: x).try(:destroy)
      end
    end

    def error_for(response_field)
      Array(self.errors.messages[:"responses_#{response_field.id}"]).first
    end

    def calculate_responses_text
      return unless self.respond_to?(:"responses_text=")
      self.responses_text = self.responses.select { |k, v| Integer(k) rescue nil }.values.join(' ')
    end

    # useful when migrating
    def calculate_sortable_values
      response_fieldable.input_fields.each do |response_field|
        if (x = response_value(response_field)).present?
          self.responses["#{response_field.id}_sortable_value"] = response_field.sortable_value(x)
        end
      end

      self.responses_will_change!
    end

    # Normalizations get run before validation.
    def normalize_responses
      return if form.blank?

      form.response_fields.each do |response_field|
        response_field.normalize_response(self.response_value(response_field), self.responses)
      end

      self.responses_will_change!
    end

    # Audits get run explicitly.
    def audit_responses
      form.response_fields.each do |response_field|
        response_field.audit_response(self.response_value(response_field), self.responses)
      end

      self.responses_will_change!
    end

  end
end

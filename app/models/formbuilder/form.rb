module Formbuilder
  class Form < ActiveRecord::Base

    has_many :response_fields, dependent: :destroy
    belongs_to :formable, polymorphic: true

    attr_accessor :show_blind, :show_admin_only

    def input_fields
      response_fields.reject { |rf| !rf.input_field }
    end

    def response_fields_json
      self.response_fields.to_json(methods: [:field_type, :cid])
    end

    def copy_response_fields!(other_form)
      other_form.response_fields.each_with_index do |response_field, i|
        self.response_fields.create(
          label: response_field.label,
          type: response_field.type,
          field_options: response_field.field_options,
          sort_order: response_field.sort_order,
          required: response_field.required,
          blind: response_field.blind,
          admin_only: response_field.admin_only
        )
      end
    end

    def multi_page?
      num_pages > 1
    end

    def num_pages
      response_fields_by_page.length
    end

    def filtered_response_fields
      query = response_fields
      query = query.reject { |rf| rf.blind? } unless show_blind
      query = query.reject { |rf| rf.admin_only? } unless show_admin_only
      query
    end

    def response_fields_by_page
      [].tap do |a|
        a.push []

        page_index = 0
        filtered_response_fields.each do |response_field|
          if response_field.field_type == 'page_break'
            a << []
          else
            a.last << response_field
          end
        end

        a.delete_if { |page| page.empty? }
        a.push([]) if a.empty?
      end
    end

    def response_fields_for_page(x)
      response_fields_by_page[x - 1] # 0-indexed
    end

  end
end

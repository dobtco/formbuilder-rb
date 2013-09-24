module Formbuilder
  class FormsController < ApplicationController

    before_filter :load_form

    def update
      existing_response_field_ids = []

      (params[:fields] || []).each_with_index do |field_params, i|
        response_field = field_params[:id].present? ?
                          @form.response_fields.find { |rf| rf.id == field_params[:id].to_i } :
                          @form.response_fields.build

        response_field.update_attributes(pick(field_params, *ResponseField::ALLOWED_PARAMS).merge(sort_order: i, type: "ResponseFields::#{field_params[:field_type].camelize}"))
        response_field.cid = field_params[:cid]
        existing_response_field_ids.push response_field.id
      end

      # destroy fields that no longer exist
      @form.response_fields.each do |response_field|
        response_field.destroy unless response_field.id.in?(existing_response_field_ids)
      end

      render json: @form.response_fields.reload
    end

    private
    def load_form
      @form = Form.find(params[:id])
    end

  end
end

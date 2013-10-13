# A controller to integrate with the Formbuilder.js frontend (https://github.com/dobtco/formbuilder)

module Formbuilder
  class FormsController < ApplicationController

    before_filter :load_form

    protect_from_forgery except: :update

    def update
      existing_response_field_ids = []
      cids = {}

      (params[:fields] || []).each_with_index do |field_params, i|
        response_field = field_params[:id].present? ?
                          @form.response_fields.find { |rf| rf.id == field_params[:id].to_i } :
                          @form.response_fields.build

        response_field.update_attributes(transformed_field_params(field_params, i))
        cids[response_field.id] = field_params[:cid]
        existing_response_field_ids.push response_field.id
      end

      # destroy fields that no longer exist
      @form.response_fields.each do |response_field|
        response_field.destroy unless response_field.id.in?(existing_response_field_ids)
      end

      @form.response_fields.reload

      @form.response_fields.each do |rf|
        rf.cid = cids[rf.id]
      end

      render json: @form.response_fields_json
    end

    private
    def load_form
      @form = Formbuilder::Form.find(params[:id])
    end

    def transformed_field_params(field_params, i)
      filtered_params = field_params.reject { |k, v|
        !k.to_sym.in?(Formbuilder::ResponseField::ALLOWED_PARAMS) || v.blank?
      }.merge(
        sort_order: i,
        type: "Formbuilder::ResponseField#{field_params[:field_type].camelize}"
      )
    end

  end
end

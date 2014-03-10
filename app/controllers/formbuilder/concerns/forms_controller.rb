# A controller to integrate with the Formbuilder.js frontend (https://github.com/dobtco/formbuilder)

module Formbuilder
  module Concerns
    module FormsController
      extend ActiveSupport::Concern

      included do
        before_filter :load_form, only: [:update]
      end

      def update
        existing_response_field_ids = []
        cids = {}

        (params[:fields] || []).each_with_index do |field_params, i|
          response_field = get_or_build_field(field_params[:id])
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

      def get_or_build_field(id_param)
        (id_param.present? && @form.response_fields.find { |rf| rf.id == id_param.to_i }) ||
        @form.response_fields.build
      end

      def transformed_field_params(field_params, i)
        filtered_params = field_params.select { |k, _|
          k.to_sym.in?(Formbuilder::ResponseField::ALLOWED_PARAMS)
        }.merge(
          sort_order: i,
          type: "Formbuilder::ResponseField#{field_params[:field_type].camelize}"
        )

        filtered_params.permit!
        filtered_params
      end

    end
  end
end

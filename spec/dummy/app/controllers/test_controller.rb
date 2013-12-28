class TestController < ApplicationController

  before_filter :load_form_and_entry

  def show_form
  end

  def post_form
    @entry.save_responses(params[:response_fields], @form.response_fields.not_admin_only)

    @entry.save(validate: false)

    respond_to do |format|
      format.json do
        render json: { ok: true }
      end

      format.html do
        if @entry.valid?
          redirect_to render_entry_path(@form, @entry)
        else
          render :show_form
        end
      end
    end
  end

  def render_entry
  end

  private
  def load_form_and_entry
    @form = Formbuilder::Form.find(params[:form_id])
    @entry = Entry.find(params[:entry_id])
  end

end
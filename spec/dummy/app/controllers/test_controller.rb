class TestController < ApplicationController

  before_filter :load_form_and_entry

  def show_form
  end

  def post_form
    @entry.save_responses(params[:response_fields], @form.response_fields.not_admin_only)

    if params[:draft_only] != 'true' && @entry.valid?
      @entry.submit!
    else
      @entry.save(validate: false)
    end

    respond_to do |format|
      format.json do
        render json: { ok: true }
      end

      format.html do
        if @entry.submitted?
          redirect_to render_entry_path(@form, @entry)
        elsif params[:draft_only] == 'true'
          redirect_to :back
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
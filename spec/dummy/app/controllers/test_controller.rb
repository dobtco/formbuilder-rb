class TestController < ApplicationController

  before_filter :load_form_and_entry

  def show_form
  end

  def post_form
    @entry.save_responses(params[:response_fields], @form.response_fields.not_admin_only)
    @entry.save(skip_validation: true)
    redirect_to :back
  end

  def render_entry
  end

  private
  def load_form_and_entry
    @form = Formbuilder::Form.find(params[:form_id])
    @entry = Entry.find(params[:entry_id])
  end

end
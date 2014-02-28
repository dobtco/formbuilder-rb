class TestController < ApplicationController

  before_filter :load_form_and_entry

  def show_form
    @current_page = [params[:page].to_i, 1].max

    if flash[:show_errors]
      @entry.valid_page?(@current_page)
    end
  end

  def post_form
    @current_page = [params[:page].to_i, 1].max

    @entry.form.show_blind = true

    @entry.save_responses(
      params[:response_fields],
      @entry.form.response_fields_for_page(@current_page),
      partial_update: true
    )

    success_path = @entry.form.num_pages == @current_page ?
                    render_entry_path(@entry.form, @entry) :
                    test_form_path(@entry.form, @entry, page: @current_page + 1)

    if @current_page != @entry.form.num_pages
      @entry.only_validate_page = @current_page
    end

    if @entry.valid?
      @entry.save(validate: false)
      redirect_to success_path
    else
      @entry.save(validate: false)

      failure_path = if @entry.errors_on_page?(@current_page)
        test_form_path(@entry.form, @entry, page: @current_page)
      else
        test_form_path(@entry.form, @entry, page: @entry.first_page_with_errors)
      end

      redirect_to failure_path, flash: { show_errors: true }
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
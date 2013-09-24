class FormsController < ApplicationController

  def show
    @form = Form.find(params[:id])
    @entry = Entry.new(form: @form)
  end

end
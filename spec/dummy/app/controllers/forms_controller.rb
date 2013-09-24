class FormsController < ApplicationController

  def show
    @form = Formbuilder::Form.find(params[:id])
    @entry = Entry.new(form: @form)
  end

end
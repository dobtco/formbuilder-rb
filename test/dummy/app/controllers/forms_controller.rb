class FormsController < ApplicationController

  def show
    @form = Form.find(params[:id])
    # @entry = @form
  end

end
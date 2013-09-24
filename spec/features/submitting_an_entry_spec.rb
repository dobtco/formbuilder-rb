require 'spec_helper'

describe 'Submitting an entry' do

  subject { page }

  describe 'The file field' do
    before do
      @form = Formbuilder::Form.create
      @field = Formbuilder::ResponseFieldText.create(form: @form)
      visit form_path(@form)
    end

    it 'should behave properly' do
      page.should have_field("response_fields[#{@field.id}]")
    end
  end

end
require 'spec_helper'
include SubmittingAnEntrySpecHelper

describe 'Submitting an entry' do

  subject { page }

  before do
    @form = FactoryGirl.create(:kitchen_sink_form)
    visit form_path(@form)
  end

  it 'should render the form fields properly' do
    @form.input_fields.each do |response_field|
      page.should have_selector('label', text: response_field.label)
    end
  end

end
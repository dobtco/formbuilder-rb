require 'spec_helper'
include SubmittingAnEntrySpecHelper

describe 'Rendering a form properly' do

  subject { page }
  let!(:form) { FactoryGirl.create(:form) }
  let!(:entry) { Entry.create(form: form, skip_validation: true) }

  context 'with a text field' do

    before do
      @rf = form.response_fields.create(label: "Textfield", type: "Formbuilder::ResponseFieldText", sort_order: 0)
      visit test_form_path(form.id, entry.id)
    end

    it 'should render the field and its label' do
      page.should have_text 'Textfield'
      page.should have_field "response_fields_#{@rf.id}"
    end

    it 'should render errors'

    it 'should render length validations'

    it 'should render min/max validations'

  end

end
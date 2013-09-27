require 'spec_helper'
include SubmittingAnEntrySpecHelper

describe 'Rendering a form properly' do

  subject { page }
  let!(:form) { FactoryGirl.create(:form) }
  let!(:entry) { e = Entry.new(form: form); e.save(validate: false); e }

  context 'with a text field' do

    before do
      form.response_fields.create(label: "Text", type: "Formbuilder::ResponseFieldText", sort_order: 0)
      visit test_form_path(form.id, entry.id)
    end

    it 'should render the field and its label' do
      # label
      # required?
      # description
    end

    it 'should render errors'

    it 'should render length validations'

    it 'should render min/max validations'

  end

end
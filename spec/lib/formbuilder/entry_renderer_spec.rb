require 'spec_helper'

describe Formbuilder::EntryRenderer do

  TEXT_FIELD_PARAMS = { label: "Text", type: "Formbuilder::ResponseFieldText", sort_order: 0 }

  let(:form) { FactoryGirl.create(:form) }
  let(:entry) { e = Entry.new(form: form); e.save(validate: false); e }

  it 'should display a label for blind fields' do
    form.response_fields.create TEXT_FIELD_PARAMS.merge(blind: true)
    Formbuilder::EntryRenderer.new(entry, form, show_blind: true).to_html.should match('Blind')
  end

  it 'should only display blind fields when instructed to' do
    form.response_fields.create TEXT_FIELD_PARAMS.merge(blind: true)
    Formbuilder::EntryRenderer.new(entry, form).to_html.should_not match('Blind')
  end

  it 'should display a label for admin only fields' do
    form.response_fields.create TEXT_FIELD_PARAMS.merge(admin_only: true)
    Formbuilder::EntryRenderer.new(entry, form).to_html.should match('Admin Only')
  end

  it 'should display placeholder text if there is no response' do
    form.response_fields.create TEXT_FIELD_PARAMS
    Formbuilder::EntryRenderer.new(entry, form).to_html.should match('No response')
  end

  it 'should display the response'

end
require 'spec_helper'

describe Formbuilder::Views::EntryDl do

  TEXT_FIELD_PARAMS = { label: "Text", type: "Formbuilder::ResponseFieldText", sort_order: 0 }

  let(:form) { FactoryGirl.create(:form) }
  let(:entry) { e = Entry.new(form: form); e.save(validate: false); e }

  it 'should display a label for blind fields' do
    form.response_fields.create TEXT_FIELD_PARAMS.merge(blind: true)
    Formbuilder::Views::EntryDl.new(entry: entry, form: form, show_blind: true).to_html.should match('Blind')
  end

  it 'should only display blind fields when instructed to' do
    form.response_fields.create TEXT_FIELD_PARAMS.merge(blind: true)
    Formbuilder::Views::EntryDl.new(entry: entry, form: form).to_html.should_not match('Blind')
  end

  it 'should display a label for admin only fields' do
    form.response_fields.create TEXT_FIELD_PARAMS.merge(admin_only: true)
    Formbuilder::Views::EntryDl.new(entry: entry, form: form).to_html.should match('Admin only')
  end

  it 'should display placeholder text if there is no response' do
    form.response_fields.create TEXT_FIELD_PARAMS
    Formbuilder::Views::EntryDl.new(entry: entry, form: form).to_html.should match('No response')
  end

  it 'should display the response' do
    rf = form.response_fields.create TEXT_FIELD_PARAMS
    entry.save_response('buzz', rf)
    entry.save(validate: false)
    Formbuilder::Views::EntryDl.new(entry: entry, form: form).to_html.should match('buzz')
  end

end
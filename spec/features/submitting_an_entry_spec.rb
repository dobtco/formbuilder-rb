require 'spec_helper'
include SubmittingAnEntrySpecHelper

describe 'Submitting an entry' do

  subject { page }
  let!(:form) { FactoryGirl.create(:kitchen_sink_form) }
  let!(:entry) { e = Entry.new(form: form); e.save(validate: false); e }

  before do
    visit form_path(form.id, entry.id)
  end

  it 'should render the form fields properly' do
    form.input_fields.each do |response_field|
      page.should have_selector('label', text: response_field.label)
    end
  end

  it 'should save and then submit responses' do
    test_field_values.each do |k, v|
      set_field(k, v)
    end

    save_draft_and_refresh

    test_field_values.each do |k, v|
      ensure_field(k, v)
    end

    # and update the draft
    test_field_values_two.each do |k, v|
      set_field(k, v)
    end

    save_draft_and_refresh

    test_field_values_two.each do |k, v|
      ensure_field(k, v)
    end

    # and submit the bid
    click_button 'Submit'

    entry.reload.should be_submitted
    current_path.should == render_entry_path(form, entry)
  end


end
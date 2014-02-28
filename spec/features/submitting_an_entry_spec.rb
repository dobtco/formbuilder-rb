require 'spec_helper'
include SubmittingAnEntrySpecHelper

describe 'Submitting an entry' do

  subject { page }

  describe 'kitchen sink' do
    let!(:form) { FactoryGirl.create(:kitchen_sink_form) }
    let!(:entry) { e = Entry.new(form: form); e.save(skip_validation: true); e }

    before do
      visit test_form_path(form.id, entry.id)
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

      normalized_test_field_values.each do |k, v|
        ensure_field(k, v)
      end

      # and update the draft
      test_field_values_two.each do |k, v|
        set_field(k, v)
      end

      save_draft_and_refresh

      normalized_test_field_values_two.each do |k, v|
        ensure_field(k, v)
      end
    end
  end

  describe 'multi-page form' do
    let!(:form) { FactoryGirl.create(:three_page_form) }
    let!(:entry) { Entry.create(form: form, skip_validation: true) }

    it 'renders the pages properly' do
      visit test_form_path(form.id, entry.id)
      page.should have_selector('label', text: 'Text1')
      page.should_not have_selector('label', text: 'Text2')
      page.should_not have_selector('label', text: 'Text3')

      visit test_form_path(form.id, entry.id, page: 2)
      page.should_not have_selector('label', text: 'Text1')
      page.should have_selector('label', text: 'Text2')
      page.should_not have_selector('label', text: 'Text3')

      visit test_form_path(form.id, entry.id, page: 3)
      page.should_not have_selector('label', text: 'Text1')
      page.should_not have_selector('label', text: 'Text2')
      page.should have_selector('label', text: 'Text3')
    end

    it 'ignores errors for previous pages, unless on the last page' do
      visit test_form_path(form.id, entry.id, page: 1)
      fill_in 'Text1', with: 'hi'
      click_button 'Next page'
      visit test_form_path(form.id, entry.id, page: 3)
      fill_in 'Text3', with: 'bye'
      click_button 'Submit'
      uri = URI.parse(current_url)
      expect("#{uri.path}?#{uri.query}").to eq test_form_path(form.id, entry.id, page: 2)
    end
  end

end
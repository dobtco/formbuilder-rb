require 'spec_helper'

module EntrySpecHelper
  def first_response_field
    form.response_fields.first
  end

  def create_entry(value)
    e = Entry.new(form: form)
    e.save_response(value, first_response_field)
    e.save(validate: false)
    e
  end

  def ensure_sort_order(*args)
    (args.length - 1).times do |i|
      ( (args[i].responses["#{first_response_field.id}_sortable_value"] || 0) <
        (args[i+1].responses["#{first_response_field.id}_sortable_value"] || 0) ).should == true
    end
  end

  def file_value
    File.open(File.expand_path('../../fixtures/test_files/text2.txt', File.dirname(__FILE__)))
  end
end

include EntrySpecHelper

describe Formbuilder::Entry do

  let!(:form) { FactoryGirl.create(:form_with_one_field) }
  let!(:entry) { e = Entry.new(form: form); e.save(validate: false); e }

  subject { entry }

  describe '#submitted?' do
    it { should_not be_submitted }

    describe 'when submitted' do
      before { entry.submit!(true) }
      it { should be_submitted }
    end
  end

  describe '#submit!' do
    it 'should validate by default' do
      entry.submit!.should == false
      entry.submit!(true).should == true
    end
  end

  describe '#unsubmit!' do
    it 'should properly unsubmit' do
      entry.submit!(true)
      entry.reload.should be_submitted
      entry.unsubmit!
      entry.reload.should_not be_submitted
    end
  end

  describe '#value_present?' do
    it 'should be true if there is a value' do
      entry.value_present?(first_response_field).should == false
      entry.responses[first_response_field.id.to_s] = 'foo'
      entry.value_present?(first_response_field).should == true
    end

    it 'should be true if there are no options for a radio/checkbox/dropdown/etc' do
      entry.value_present?(first_response_field).should == false
      first_response_field.update_attributes(type: 'Formbuilder::ResponseFieldCheckboxes')
      entry.value_present?(first_response_field).should == true
    end

    it 'should be true if value is a hash and has at least one response' do
      first_response_field.update_attributes(type: 'Formbuilder::ResponseFieldTime')
      entry.value_present?(first_response_field).should == false
      entry.responses[first_response_field.id.to_s] = { 'am_pm' => 'am' }.to_yaml
      entry.value_present?(first_response_field).should == false
      entry.responses[first_response_field.id.to_s] = { 'minutes' => '06' }.to_yaml
      entry.value_present?(first_response_field).should == true
    end
  end

  describe '#value_present_or_checkboxes?' do
    pending 'need to investigate how necessary this method really is'
  end

  describe '#response_value' do
    it 'should unserialize a value if necessary' do
      first_response_field.update_attributes(type: 'Formbuilder::ResponseFieldCheckboxes')
      entry.responses[first_response_field.id.to_s] = { a: 'b' }.to_yaml
      entry.response_value(first_response_field).should == { a: 'b' }
    end

    # this might not be necessary?
    it 'should handle a blank checkbox value' do
      first_response_field.update_attributes(type: 'Formbuilder::ResponseFieldCheckboxes')
      entry.response_value(first_response_field).should == nil
    end
  end

  describe '#save_responses' do
    # let's not go overboard here. most of this functionality is covered by feature specs.
    it 'should behave properly' do
      entry.save_responses({ "#{first_response_field.id}" => 'boo' }, form.response_fields)
      entry.response_value(first_response_field).should == 'boo'
    end
  end

  describe '#destroy_response' do
    it 'should remove the response and its sortable value' do
      # Setup
      entry.save_responses({ "#{first_response_field.id}" => 'boo' }, form.response_fields)
      entry.response_value(first_response_field).should == 'boo'
      entry.responses["#{first_response_field.id}_sortable_value"].should be_present

      # Destroy
      entry.destroy_response(first_response_field)
      entry.response_value(first_response_field).should be_nil
      entry.responses["#{first_response_field.id}_sortable_value"].should be_nil
    end

    it 'should remove an uploaded file' do
      # Upload
      first_response_field.update_attributes(type: 'Formbuilder::ResponseFieldFile')
      entry.save_responses({ "#{first_response_field.id}" => file_value }, form.response_fields.reload)
      attachment_id = entry.response_value(first_response_field)
      Formbuilder::EntryAttachment.find(attachment_id).should be_present

      # Destroy
      entry.destroy_response(first_response_field)
      entry.response_value(first_response_field).should be_nil
      entry.responses["#{first_response_field.id}_sortable_value"].should be_nil
      Formbuilder::EntryAttachment.where(id: attachment_id).first.should_not be_present
    end
  end

  describe '#calculate_responses_text' do
    it 'should calculate the text-only values of the responses' do
      first_response_field.update_attributes(type: 'Formbuilder::ResponseFieldDropdown', field_options: { 'options' => [{'checked' => 'false', 'label' => 'Choice #1'}] })
      entry.responses[first_response_field.id.to_s] = 'Choice #1'
      entry.calculate_responses_text
      entry.responses_text.should match 'Choice #1'
    end
  end

  describe 'normalizing & auditing responses' do
    it 'should run all audits when saving' do
      first_response_field.update_attributes(type: 'Formbuilder::ResponseFieldAddress')
      entry.responses[first_response_field.id.to_s] = { 'street' => 'hi' }.to_yaml
      entry.save(validate: false)
      entry.responses["#{first_response_field.id}_x"].should be_nil
      entry.submit!(true)
      entry.responses["#{first_response_field.id}_x"].should == Geocoder::Lookup::Test.read_stub(nil)[0]['latitude']
    end

    it 'should run the file audit' do
      first_response_field.update_attributes(type: 'Formbuilder::ResponseFieldFile')
      entry.save_responses({ "#{first_response_field.id}" => file_value }, form.response_fields.reload)

      entry.responses["#{first_response_field.id}_filename"].should be_nil
      entry.submit!(true)
      entry.responses["#{first_response_field.id}_filename"].should == 'text2.txt'

    end
  end

  describe 'sortable values' do
    it 'should sort dates properly' do
      first_response_field.update_attributes(type: 'Formbuilder::ResponseFieldDate')
      e1 = create_entry({ 'month' => '05', 'day' => '29', 'year' => '2001'})
      e2 = create_entry({ 'month' => '01', 'day' => '2', 'year' => '2012'})
      ensure_sort_order(e1, e2)
    end

    it 'should sort times properly' do
      first_response_field.update_attributes(type: 'Formbuilder::ResponseFieldTime')
      e1 = create_entry({ 'hours' => '03', 'minutes' => '29', 'seconds' => '00', 'am_pm' => 'AM'})
      e2 = create_entry({ 'hours' => '03', 'minutes' => '29', 'seconds' => '01', 'am_pm' => 'AM'})
      e3 = create_entry({ 'hours' => '01', 'minutes' => '29', 'seconds' => '01', 'am_pm' => 'PM'})
      e4 = create_entry({ 'hours' => '11', 'minutes' => '29', 'seconds' => '01', 'am_pm' => 'PM'})
      ensure_sort_order(e1, e2, e3, e4)
    end

    it 'should sort files properly' do
      first_response_field.update_attributes(type: 'Formbuilder::ResponseFieldFile')
      e1 = create_entry(nil)
      e2 = create_entry(file_value)
      ensure_sort_order(e1, e2)
    end

    it 'should sort checkboxes individually' do
      first_response_field.update_attributes(type: 'Formbuilder::ResponseFieldCheckboxes',
                                             field_options: { 'options' => [{'checked' => 'false', 'label' => 'Choice #1'}] })

      e1 = create_entry({ '0' => 'on' })
      e2 = create_entry({})

      e1.responses["#{first_response_field.id}_sortable_values_Choice #1"].should == true
      e2.responses["#{first_response_field.id}_sortable_values_Choice #1"].should == false
    end

    it 'should sort prices properly' do
      first_response_field.update_attributes(type: 'Formbuilder::ResponseFieldPrice')
      e1 = create_entry({ 'dollars' => '05', 'cents' => '02' })
      e2 = create_entry({ 'dollars' => '09', 'cents' => '1' })
      ensure_sort_order(e1, e2)
    end

    it 'should sort addresses properly' do
      first_response_field.update_attributes(type: 'Formbuilder::ResponseFieldAddress')
      e1 = create_entry({ 'street' => 'a street' })
      e2 = create_entry({ 'street' => 'b street' })
      ensure_sort_order(e1, e2)
    end

    it 'should sort text properly, obvz' do
      e1 = create_entry('BBBaaaaa')
      e2 = create_entry('aaaBBB')
      ensure_sort_order(e1, e2)
    end
  end

end

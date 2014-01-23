require 'spec_helper'

def create_entry(value)
  e = Entry.new(form: form, skip_validation: true)
  e.save_response(value, first_field)
  e.save
  e
end

def ensure_sort_order(*args)
  (args.length - 1).times do |i|
    ( (args[i].responses["#{first_field.id}_sortable_value"] || 0) <
      (args[i+1].responses["#{first_field.id}_sortable_value"] || 0) ).should == true
  end
end

def change_field_type(new_field_type, additional_params = {})
  first_field.update_attributes({ type: new_field_type }.merge(additional_params))
  first_field.becomes!(new_field_type.constantize)
end

describe Formbuilder::Entry do

  let!(:form) { FactoryGirl.create(:form_with_one_field) }
  let!(:entry) { e = Entry.new(form: form, skip_validation: true); e.save; e }
  let(:first_field) { form.response_fields.first }
  let(:file_value) { File.open(File.expand_path('../../fixtures/test_files/text2.txt', File.dirname(__FILE__))) }

  subject { entry }

  describe 'callbacks' do
    describe 'normalize responses' do
      it 'gets called before validation' do
        entry.should_receive(:normalize_responses)
        entry.valid?
      end
    end

    describe 'calculate_responses_text' do
      it 'gets called when responses change and entry is saved' do
        entry.should_receive(:calculate_responses_text).exactly(:once)
        entry.save_responses({ "#{first_field.id}" => 'boo' }, form.response_fields)
        entry.save
      end
    end
  end

  describe '#value_present?' do
    it 'should be true if there is a value' do
      entry.value_present?(first_field).should == false
      entry.responses[first_field.id.to_s] = 'foo'
      entry.value_present?(first_field).should == true
    end

    context 'Formbuilder::ResponseFieldCheckboxes' do
      let(:first_field_checkboxes) { first_field.becomes!(Formbuilder::ResponseFieldCheckboxes) }

      it 'should be true when there are no options' do
        entry.value_present?(first_field_checkboxes).should == true
      end

      context 'when there are options' do
        before { first_field_checkboxes.field_options['options'] = [{ 'label' => 'foo', 'checked' => 'false' }] }

        it 'should be false' do
          entry.value_present?(first_field_checkboxes).should == false
        end
      end
    end

    context 'when the field is serialized' do
      let(:first_field_time) { first_field.becomes!(Formbuilder::ResponseFieldTime) }

      it 'should be true if it has at least one response' do
        entry.value_present?(first_field_time).should == false
        entry.responses[first_field_time.id.to_s] = { 'am_pm' => 'am' }.to_yaml
        entry.value_present?(first_field_time).should == false
        entry.responses[first_field_time.id.to_s] = { 'minutes' => '06' }.to_yaml
        entry.value_present?(first_field_time).should == true
      end
    end
  end

  describe '#response_value' do
    context 'when value is serialized' do
      let(:first_field_serialized) { first_field.becomes!(Formbuilder::ResponseFieldCheckboxes) }

      it 'should unserialize a value if necessary' do
        entry.responses[first_field_serialized.id.to_s] = { a: 'b' }.to_yaml
        entry.response_value(first_field_serialized).should == { a: 'b' }
      end
    end
  end

  describe '#save_responses' do
    # let's not go overboard here. most of this functionality is covered by feature specs.
    it 'should behave properly' do
      entry.save_responses({ "#{first_field.id}" => 'boo' }, form.response_fields)
      entry.response_value(first_field).should == 'boo'
    end
  end

  describe '#destroy_response' do
    it 'should remove the response and its sortable value' do
      # Setup
      entry.save_responses({ "#{first_field.id}" => 'boo' }, form.response_fields)
      entry.response_value(first_field).should == 'boo'
      entry.responses["#{first_field.id}_sortable_value"].should be_present

      # Destroy
      entry.destroy_response(first_field)
      entry.response_value(first_field).should be_nil
      entry.responses["#{first_field.id}_sortable_value"].should be_nil
    end

    context 'Formbuilder::ResponseFieldFile' do
      let(:first_field_file) { first_field.becomes!(Formbuilder::ResponseFieldFile); }
      let(:attachment_id) { entry.response_value(first_field_file) }

      before do
        first_field.update_attributes(type: 'Formbuilder::ResponseFieldFile')
        entry.save_responses({ "#{first_field_file.id}" => file_value }, form.reload.response_fields)
      end

      it 'uploads properly' do
        Formbuilder::EntryAttachment.find(attachment_id).should be_present
      end

      it 'destroys explicitly' do
        entry.destroy_response(first_field_file)
        entry.response_value(first_field_file).should be_nil
        entry.responses["#{first_field_file.id}_sortable_value"].should be_nil
        Formbuilder::EntryAttachment.where(id: attachment_id).first.should_not be_present
      end

      it 'destroys when changing value' do
        prev_attachment_id = attachment_id
        entry.save_responses({ "#{first_field_file.id}" => file_value }, form.reload.response_fields)
        Formbuilder::EntryAttachment.where(id: prev_attachment_id).first.should_not be_present
      end

      # Because <input type='file'> can't have an existing file, we preserve the current
      # value if the input is blank.
      it 'preserves when value is blank' do
        prev_attachment_id = attachment_id
        entry.save_responses({ "#{first_field_file.id}" => '' }, form.reload.response_fields)
        Formbuilder::EntryAttachment.where(id: prev_attachment_id).first.should be_present
      end
    end
  end

  describe '#calculate_responses_text' do
    let(:first_field_number) { first_field.becomes!(Formbuilder::ResponseFieldNumber) }

    it 'should calculate the text-only values of the responses' do
      entry.save_responses({ "#{first_field_number.id}" => '123' }, form.response_fields)
      entry.responses["#{first_field_number.id}"].should == '123'
      entry.responses["#{first_field_number.id}_sortable_value"].should == '123'
      entry.save
      entry.responses_text.should == '123'
    end
  end

  describe 'normalize responses' do
    before do
      first_field.update_attributes(type: 'Formbuilder::ResponseFieldWebsite')
      entry.reload
    end

    it 'functions properly' do
      # does not need normalization
      entry.responses[first_field.id.to_s] = 'http://www.google.com'
      entry.normalize_responses
      entry.responses[first_field.id.to_s].should == 'http://www.google.com'

      # needs normalization
      entry.responses[first_field.id.to_s] = 'www.google.com'
      entry.normalize_responses
      entry.responses[first_field.id.to_s].should == 'http://www.google.com'
    end
  end

  describe 'auditing responses' do
    before do
      first_field.update_attributes(type: 'Formbuilder::ResponseFieldAddress')
      entry.reload
    end

    it 'should run all audits when called explicitly' do
      entry.responses[first_field.id.to_s] = { 'street' => 'hi' }.to_yaml
      entry.skip_validation = true
      entry.save
      entry.responses["#{first_field.id}_x"].should be_nil
      entry.audit_responses
      entry.responses["#{first_field.id}_x"].should == Geocoder::Lookup::Test.read_stub(nil)[0]['latitude']
    end
  end

end

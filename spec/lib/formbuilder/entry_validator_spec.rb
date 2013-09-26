require 'spec_helper'

describe Formbuilder::EntryValidator do

  let!(:form) { FactoryGirl.create(:form) }
  let!(:entry) { e = Entry.new(form: form); e.save(validate: false); e }

  describe '#validate' do
    before do
      form.response_fields.create(label: "Text", type: "Formbuilder::ResponseFieldText", sort_order: 0, required: true)
    end

    it 'should always validate if there is no form' do
      entry.should_not be_valid
      entry.form = nil
      entry.should be_valid
    end

    it 'should always validate if it was already submitted' do
      entry.should_not be_valid
      entry.submit!(true)
      entry.should be_valid
    end

    it 'should validate if the :skip_validation flag is passed' do
      entry.should_not be_valid
      entry.skip_validation = true
      entry.should be_valid
    end
  end

  describe 'ResponseFieldText' do
    let(:field) { form.response_fields.create(label: "Text", type: "Formbuilder::ResponseFieldText", sort_order: 0) }

    it 'required' do
      field.update_attributes(required: true)
      entry.should_not be_valid
      entry.save_response('Boo', field)
      entry.should be_valid
    end

    it 'min/max length characters' do
      field.update_attributes(field_options: { 'minlength' => '5', 'maxlength' => '10' })
      entry.should be_valid
      entry.save_response('Boo', field)
      entry.should_not be_valid
      entry.save_response('Boooo', field)
      entry.should be_valid
      entry.save_response('Boooooooooooooooooooo', field)
      entry.should_not be_valid
      entry.save_response('Boooo', field)
      entry.should be_valid
    end

    it 'min/max length words' do
      field.update_attributes(field_options: { 'minlength' => '2', 'maxlength' => '3', 'min_max_length_units' => 'words' })
      entry.should be_valid
      entry.save_response('Boo', field)
      entry.should_not be_valid
      entry.save_response('Boo hoo', field)
      entry.should be_valid
      entry.save_response('Boo hoo hoo', field)
      entry.should be_valid
      entry.save_response('Booo hoo hoo hooo', field)
      entry.should_not be_valid
    end
  end

  describe 'ResponseFieldAddress' do
    let(:field) { form.response_fields.create(label: "Address", type: "Formbuilder::ResponseFieldAddress", sort_order: 0) }

    it 'required' do
      field.update_attributes(required: true)
      entry.should_not be_valid
      entry.save_response({'street' => '123'}, field)
      entry.should be_valid
    end
  end

  describe 'ResponseFieldDate' do
    let(:field) { form.response_fields.create(label: "Date", type: "Formbuilder::ResponseFieldDate", sort_order: 0) }

    it 'validates properly' do
      entry.should be_valid
      entry.save_response({'month' => '2'}, field)
      entry.should_not be_valid
      entry.save_response({'month' => '2', 'day' => '3'}, field)
      entry.should_not be_valid
      entry.save_response({'month' => '2', 'day' => '3', 'year' => '2011'}, field)
      entry.should be_valid

      # @todo  automatically add 20** or 19** to dates
    end
  end

  describe 'ResponseFieldEmail' do
    let(:field) { form.response_fields.create(label: "Email", type: "Formbuilder::ResponseFieldEmail", sort_order: 0) }

    it 'validates properly' do
      entry.should be_valid
      entry.save_response('a', field)
      entry.should_not be_valid
      entry.save_response('a@a.com', field)
      entry.should be_valid
    end
  end

  describe 'ResponseFieldNumber' do
    let(:field) { form.response_fields.create(label: "Number", type: "Formbuilder::ResponseFieldNumber", sort_order: 0) }

    it 'min/max' do
      field.update_attributes(field_options: { 'min' => '5', 'max' => '10' })
      entry.should be_valid
      entry.save_response('1', field)
      entry.should_not be_valid
      entry.save_response('4.99999', field)
      entry.should_not be_valid
      entry.save_response('5.01', field)
      entry.should be_valid
      entry.save_response('10.00', field)
      entry.should be_valid
      entry.save_response('10.9', field)
      entry.should_not be_valid
    end

    it 'integer only' do
      field.update_attributes(field_options: { 'integer_only' => true })
      entry.should be_valid
      entry.save_response('1.2', field)
      entry.should_not be_valid
      entry.save_response('1.0', field)
      entry.should_not be_valid
      entry.save_response('1', field)
      entry.should be_valid
    end
  end

  describe 'ResponseFieldPrice' do
    let(:field) { form.response_fields.create(label: "Price", type: "Formbuilder::ResponseFieldPrice", sort_order: 0) }

    it 'validates properly' do
      entry.should be_valid
      entry.save_response({ 'dollars' => 'a' }, field)
      entry.should_not be_valid
      entry.save_response({ 'dollars' => '0' }, field)
      entry.should_not be_valid
      entry.save_response({ 'dollars' => '1a' }, field)
      entry.should_not be_valid
      entry.save_response({ 'dollars' => '1' }, field)
      entry.should be_valid
      entry.save_response({ 'cents' => 'a' }, field)
      entry.should_not be_valid
      entry.save_response({ 'cents' => '0' }, field)
      entry.should_not be_valid
      entry.save_response({ 'cents' => '1a' }, field)
      entry.should_not be_valid
      entry.save_response({ 'cents' => '1' }, field)
      entry.should be_valid
      entry.save_response({ 'dollars' => '3a', 'cents' => '1' }, field)
      entry.should_not be_valid
    end
  end

  describe 'ResponseFieldTime' do
    let(:field) { form.response_fields.create(label: "Time", type: "Formbuilder::ResponseFieldTime", sort_order: 0) }

    it 'validates properly' do
      entry.should be_valid
      entry.save_response({'hours' => '0'}, field)
      entry.should_not be_valid
      entry.save_response({'hours' => '0', 'minutes' => '1'}, field)
      entry.should_not be_valid
      entry.save_response({'hours' => '1', 'minutes' => '3'}, field)
      entry.should be_valid
    end
  end

  describe 'ResponseFieldWebsite' do
    let(:field) { form.response_fields.create(label: "Website", type: "Formbuilder::ResponseFieldWebsite", sort_order: 0) }

    it 'validates properly' do
      entry.should be_valid
      # @todo add real validations for website field?
    end
  end

end
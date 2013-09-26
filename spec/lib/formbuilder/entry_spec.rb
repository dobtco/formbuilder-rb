require 'spec_helper'

module EntrySpecHelper
  def first_response_field
    form.response_fields.first
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
      entry.responses[first_response_field.id.to_s] = 'foo'
      entry.value_present?(first_response_field).should == true
    end

    it 'should be true if there are no options for a radio/checkbox/dropdown/etc'
    it 'should be true if value is a hash and has at least one response'
  end

  describe '#value_present_or_checkboxes?' do
    pending 'need to investigate how necessary this method really is'
  end

  describe '#response_value' do
    it 'should unserialize a value if necessary'
    it 'should handle a blank checkbox value' # this might not be necessary?
  end

  describe '#save_responses' do
    # let's not go overboard here.
    # most of this functionality is covered by feature specs.
    it 'should behave properly'
  end

  describe '#destroy_response' do
    it 'should remove the response and its sortable value'
    it 'should remove an uploaded file'
  end

  describe '#calculate_responses_text' do
    it 'should calculate the text-only values of the responses'
  end

  describe 'normalizing & auditing responses' do
    it 'should only occur when saving'
    it 'should run all audits'
  end

  describe 'sortable values' do
    it 'should sort dates properly'
    it 'should sort times properly'
    it 'should sort files properly'
    it 'should sort checkboxes individually'
    it 'should sort prices properly'
    it 'should sort text properly, obvz'
  end

end

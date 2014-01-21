require 'spec_helper'

describe Formbuilder::ResponseFieldCheckboxes do

  let(:response_field) do
    Formbuilder::ResponseFieldCheckboxes.new(
      field_options: { 'options' => [{'label' => 'foo', 'checked' => false}]}
    )
  end
  subject { response_field }
  subject(:rf) { response_field }

  describe '#normalize_response' do
    it 'calculates the individual sortable values' do
      all_responses = {}
      rf.normalize_response({'foo' => true}, all_responses)
      all_responses["#{rf.id}_sortable_values_foo"].should eq true
    end
  end

  describe '#transform_raw_value' do
    let(:entry) { Entry.new }

    it 'transforms the options properly' do
      transformed = rf.transform_raw_value({ '0' => 'on' }, entry)
      transformed['foo'].should == true
    end

    it 'transforms the other option' do
      transformed = rf.transform_raw_value({ 'other_checkbox' => 'on', 'other' => 'bar' }, entry)
      transformed['Other'].should == 'bar'
    end

    it 'does not save the other option unless the checkbox is checked' do
      transformed = rf.transform_raw_value({ 'other_checkbox' => nil, 'other' => 'bar' }, entry)
      transformed['Other'].should == nil
    end

    it 'sets the _present attribute' do
      rf.transform_raw_value({ '0' => 'on' }, entry)
      entry.responses["#{rf.id}_present"].should == true
      rf.transform_raw_value({ '0' => nil }, entry)
      entry.responses["#{rf.id}_present"].should == nil
      rf.transform_raw_value({ 'other_checkbox' => 'on', 'other' => 'z' }, entry)
      entry.responses["#{rf.id}_present"].should == true
    end
  end

end

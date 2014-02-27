require 'spec_helper'

describe Formbuilder::ResponseFieldTable do

  let(:response_field) do
    Formbuilder::ResponseFieldTable.new(
      field_options: { 'columns' => [{'label' => 'column one'}] }
    )
  end
  subject { response_field }
  subject(:rf) { response_field }

  describe '#normalize_response' do
    it 'calculates the individual sortable values' do
      all_responses = {}
      rf.normalize_response({'column one' => ['1', '2', '3.5', 'asdf']}, all_responses)
      all_responses["#{rf.id}_sum_column one"].should eq 6.5
    end

    it 'calculates the sums' do
      all_responses = {}
      rf.normalize_response({'column one' => ['asdfasdf', 'fasdf']}, all_responses)
      all_responses["#{rf.id}_sum_column one"].should eq 0
    end
  end

  describe '#transform_raw_value' do
    let(:entry) { Entry.new }

    before do
      response_field.update_attributes(
        field_options: { 'columns' => [{'label' => 'column one'},
                                       {'label' => 'column two'}] }
      )
    end

    it 'transforms the options properly' do
      transformed = rf.transform_raw_value({ '0' => ['foo', 'bar'] }, entry)
      transformed['column one'].should == ['foo', 'bar']
    end

    it 'preserves rows with one input' do
      transformed = rf.transform_raw_value({ '0' => ['', 'bar'], '1' => ['baz', ''] }, entry)
      transformed['column one'].should == ['', 'bar']
      transformed['column two'].should == ['baz', '']

    end

    it 'removes blank rows' do
      transformed = rf.transform_raw_value({ '0' => ['', 'bar'], '1' => ['', 'baz'] }, entry)
      transformed['column one'].should == ['bar']
      transformed['column two'].should == ['baz']
    end

    # it 'transforms the other option' do
    #   transformed = rf.transform_raw_value({ 'other_checkbox' => 'on', 'other' => 'bar' }, entry)
    #   transformed['Other'].should == 'bar'
    # end

    # it 'does not save the other option unless the checkbox is checked' do
    #   transformed = rf.transform_raw_value({ 'other_checkbox' => nil, 'other' => 'bar' }, entry)
    #   transformed['Other'].should == nil
    # end

    # it 'sets the _present attribute' do
    #   rf.transform_raw_value({ '0' => 'on' }, entry)
    #   entry.responses["#{rf.id}_present"].should == true
    #   rf.transform_raw_value({ '0' => nil }, entry)
    #   entry.responses["#{rf.id}_present"].should == nil
    #   rf.transform_raw_value({ 'other_checkbox' => 'on', 'other' => 'z' }, entry)
    #   entry.responses["#{rf.id}_present"].should == true
    # end
  end

  describe '#render_entry_text' do
    it 'functions properly' do
      expect(rf.render_entry_text({'column one' => ['bar', 'baz']})).to eq 'column one: bar, baz'
    end
  end

end

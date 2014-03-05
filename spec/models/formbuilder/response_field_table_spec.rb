require 'spec_helper'

describe Formbuilder::ResponseFieldTable do

  let(:response_field) do
    Formbuilder::ResponseFieldTable.new(
      field_options: { 'columns' => [{'label' => 'column one'}],
                       'column_totals' => true }
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

    it 'doesnt choke on nils' do
      transformed = rf.transform_raw_value({ }, entry)
      transformed['column one'].should == nil
      transformed['column two'].should == nil
    end
  end

  describe '#render_entry_text' do
    it 'functions properly' do
      expect(rf.render_entry_text({'column one' => ['bar', 'baz']})).to eq 'column one: bar, baz'
    end
  end

  describe '#render_entry' do
    it 'does not trip on blanks' do
      rendered = rf.render_entry(
        {'column one' => ['bar', 'baz']},
        entry: OpenStruct.new(get_responses: {})
      )
      expect(rendered).to match 'bar'
      expect(rendered).to match 'baz'
      expect(rendered).to_not match '0'
    end

    it 'does not render zeroes' do
      rendered = rf.render_entry(
        {'column one' => ['bar', 'baz']},
        entry: OpenStruct.new(get_responses: {"#{rf.id}_sum_column one" => '0.0'})
      )
      expect(rendered).to match 'bar'
      expect(rendered).to match 'baz'
      expect(rendered).to_not match '0'
    end

    it 'renders sums greater than zero' do
      rendered = rf.render_entry(
        {'column one' => ['bar', '1', '1.5']},
        entry: OpenStruct.new(get_responses: {"#{rf.id}_sum_column one" => '2.5'})
      )
      expect(rendered).to match 'bar'
      expect(rendered).to match '1'
      expect(rendered).to match '1.5'
      expect(rendered).to match '2.5'
    end
  end

  describe '#render_input' do
    it 'renders properly' do
      rendered = rf.render_input({})
      expect(rendered).to match("<input")
    end

    context 'with default row values' do
      before do
        rf.field_options['preset_values'] = {'column one' => ['p1', 'p2']}
        rf.field_options['minrows'] = 2
        rf.save
      end

      it 'renders properly' do
        rendered = rf.render_input({})
        expect(rendered).to match("value='p1'")
        expect(rendered).to match("value='p2'")
        expect(rendered).to match("readonly")
      end
    end
  end

end

require 'spec_helper'

describe Formbuilder::ResponseFieldRadio do

  let(:response_field) do
    Formbuilder::ResponseFieldRadio.new(
      field_options: { 'options' => [{'label' => 'foo', 'checked' => false}]}
    )
  end
  subject { response_field }
  subject(:rf) { response_field }

  describe '#transform_raw_value' do
    before { rf.save }
    let(:entry) { Entry.new }

    it 'does not set the other option if raw_value is not other' do
      transformed = rf.transform_raw_value('Goats', entry, { response_field_params: { "#{rf.id}_other" => 'foo' } })
      transformed.should == 'Goats'
      entry.responses["#{rf.id}_other"].should == nil
    end

    it 'sets the other option on the entry if raw_value is other' do
      transformed = rf.transform_raw_value('Other', entry, { response_field_params: { "#{rf.id}_other" => 'foo' } })
      transformed.should == 'Other'
      entry.responses["#{rf.id}_other"].should == 'foo'
    end
  end

end

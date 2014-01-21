require 'spec_helper'

describe Formbuilder::ResponseFieldAddress do

  let(:response_field) { Formbuilder::ResponseFieldAddress.new }
  subject { response_field }
  subject(:rf) { response_field }

  describe '#audit_response' do
    it 'geocodes properly' do
      Geocoder.should_receive(:coordinates).and_return([1, 1])
      all_responses = {}
      response_field.audit_response({ 'street' => 'New York, NY, US' }, all_responses)
      expect(all_responses["#{response_field.id}_x"]).to eq 1
    end
  end

  describe '#sortable_value' do
    it 'functions properly' do
      expect(rf.sortable_value({'city' => 'zzzz', 'street' => 'adams town'})).to be < rf.sortable_value({'street' => 'cffff'})
      expect(rf.sortable_value({'city' => 'aaaa', 'street' => 'zzzz'})).to be > rf.sortable_value({'street' => 'cffff'})
    end
  end

end

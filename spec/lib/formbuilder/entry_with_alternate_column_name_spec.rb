require 'spec_helper'

describe EntryWithAlternateColumnName do

  let!(:form) { FactoryGirl.create(:form_with_one_field) }
  let!(:entry) { e = EntryWithAlternateColumnName.new(form: form, skip_validation: true); e.save; e }
  let(:first_field) { form.response_fields.first }

  subject { entry }

  describe '#value_present?' do
    it 'should be true if there is a value' do
      entry.value_present?(first_field).should == false
      entry.responses_alt[first_field.id.to_s] = 'foo'
      entry.value_present?(first_field).should == true
    end
  end

  describe '#response_value' do
    context 'when value is serialized' do
      let(:first_field_serialized) { first_field.becomes!(Formbuilder::ResponseFieldCheckboxes) }

      it 'should unserialize a value if necessary' do
        entry.responses_alt[first_field_serialized.id.to_s] = { a: 'b' }.to_yaml
        entry.response_value(first_field_serialized).should == { a: 'b' }
      end
    end
  end

  describe '#save_responses' do
    it 'should behave properly' do
      entry.save_responses({ "#{first_field.id}" => 'boo' }, form.response_fields)
      entry.response_value(first_field).should == 'boo'
    end
  end

end

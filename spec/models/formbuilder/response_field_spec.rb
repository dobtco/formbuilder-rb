require 'spec_helper'

describe Formbuilder::ResponseField do

  let(:response_field) { Formbuilder::ResponseFieldText.new }
  subject { response_field }

  it { should be_valid }

  describe '#options_array' do
    its(:options_array) { should be_empty }

    context 'with options' do
      before { response_field.field_options['options'] = [{'checked' => 'false', 'label' => 'Choice #1'},
                                                          {'checked' => 'false', 'label' => 'Choice #2'}] }

      its(:options_array) { should == ['Choice #1', 'Choice #2'] }
    end
  end

end
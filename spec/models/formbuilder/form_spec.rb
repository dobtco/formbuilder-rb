require 'spec_helper'

describe Formbuilder::Form do

  let(:form) { Formbuilder::Form.new }
  subject { form }

  it { should be_valid }
  it { should respond_to(:formable) }
  it { should respond_to(:response_fields) }

  describe '#copy_response_fields!' do
    let!(:other_form) do
      f = Formbuilder::Form.create
      f.response_fields.create(type: 'Formbuilder::ResponseFieldText', label: 'foo')
      f
    end

    it 'copies properly' do
      form.save
      form.response_fields.count.should == 0
      form.copy_response_fields!(other_form)
      form.response_fields.count.should == 1
    end
  end

end
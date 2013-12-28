require 'spec_helper'

describe Formbuilder::Form do

  let(:form) { Formbuilder::Form.new }
  subject { form }

  it { should be_valid }
  it { should respond_to(:formable) }
  it { should respond_to(:response_fields) }

end
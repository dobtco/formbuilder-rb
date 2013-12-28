require 'spec_helper'

describe Formbuilder::ResponseField do

  let(:response_field) { Formbuilder::ResponseFieldText.new }
  subject { response_field }

  it { should be_valid }

end
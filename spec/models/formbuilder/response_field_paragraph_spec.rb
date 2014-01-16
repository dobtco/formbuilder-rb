require 'spec_helper'

describe Formbuilder::ResponseFieldParagraph do

  let(:response_field) { Formbuilder::ResponseFieldParagraph.new }
  subject { response_field }

  describe '#render_entry' do
    INPUT = "blah blah\n\nhttp://www.google.com asldfkj"
    EXPECTED_OUTPUT = %Q{<p>blah blah</p>\n\n<p><a href="http://www.google.com">http://www.google.com</a> asldfkj</p>}

    it 'autolinks properly' do
      expect(response_field.render_entry(INPUT)).to eq EXPECTED_OUTPUT
    end
  end

end

require 'spec_helper'

describe Formbuilder::ResponseFieldTime do

  let!(:form) { Formbuilder::Form.create }
  let!(:response_field) { Formbuilder::ResponseFieldTime.create(form: form) }
  let!(:entry) { Entry.create(form: form) }

  subject { response_field }
  subject(:rf) { response_field }

  describe '#render_input' do
    it 'renders properly' do
      rendered_html = rf.render_input(nil)
      expect(rendered_html).to match 'HH'
      expect(rendered_html).to match 'SS'
    end

    context 'with seconds field disabled' do
      before { rf.update_attributes(field_options: { 'disable_seconds' => true } )}

      it 'does not render the seconds field' do
        rendered_html = rf.render_input(nil)
        expect(rendered_html).to match 'HH'
        expect(rendered_html).to_not match 'SS'
      end
    end
  end

end

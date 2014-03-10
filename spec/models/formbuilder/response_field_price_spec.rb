require 'spec_helper'

describe Formbuilder::ResponseFieldPrice do

  let!(:form) { Formbuilder::Form.create }
  let!(:response_field) { Formbuilder::ResponseFieldPrice.create(form: form) }
  let!(:entry) { Entry.create(form: form) }

  subject { response_field }
  subject(:rf) { response_field }

  describe '#render_input' do
    it 'renders properly' do
      rendered_html = rf.render_input(nil)
      expect(rendered_html).to match 'Dollars'
      expect(rendered_html).to match 'Cents'
    end

    context 'with cents field disabled' do
      before { rf.update_attributes(field_options: { 'disable_cents' => true } )}

      it 'does not render the cents field' do
        rendered_html = rf.render_input(nil)
        expect(rendered_html).to match 'Dollars'
        expect(rendered_html).to_not match 'Cents'
      end
    end
  end

end

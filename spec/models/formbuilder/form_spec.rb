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

  describe '#num_pages' do
    before { form.save }

    context 'no response fields' do
      its(:num_pages) { should eq 1 }
    end

    context 'multiple response fields' do
      before do
        form.response_fields.create(type: 'Formbuilder::ResponseFieldText', label: 'foo')
        form.response_fields.create(type: 'Formbuilder::ResponseFieldParagraph', label: 'foo2')
      end

      its(:num_pages) { should eq 1 }
    end

    context '2 pages' do
      before do
        form.response_fields.create(type: 'Formbuilder::ResponseFieldText', label: 'foo')
        form.response_fields.create(type: 'Formbuilder::ResponseFieldPageBreak')
        form.response_fields.create(type: 'Formbuilder::ResponseFieldParagraph', label: 'foo2')
      end

      its(:num_pages) { should eq 2 }
    end

    context 'with 3 pages' do
      before do
        form.response_fields.create(type: 'Formbuilder::ResponseFieldText', label: 'foo')
        form.response_fields.create(type: 'Formbuilder::ResponseFieldPageBreak')
        form.response_fields.create(type: 'Formbuilder::ResponseFieldParagraph', label: 'foo2')
        form.response_fields.create(type: 'Formbuilder::ResponseFieldPageBreak')
        form.response_fields.create(type: 'Formbuilder::ResponseFieldText', label: 'foo3')
      end

      its(:num_pages) { should eq 3 }
    end

    context 'with admin only fields' do
      before do
        form.response_fields.create(type: 'Formbuilder::ResponseFieldText', label: 'foo')
        form.response_fields.create(type: 'Formbuilder::ResponseFieldPageBreak')
        form.response_fields.create(type: 'Formbuilder::ResponseFieldParagraph', label: 'foo2', admin_only: true)
        form.response_fields.create(type: 'Formbuilder::ResponseFieldPageBreak')
        form.response_fields.create(type: 'Formbuilder::ResponseFieldText', label: 'foo3')
      end

      context 'showing admin only' do
        before { form.show_admin_only = true }
        its(:num_pages) { should eq 3 }
      end

      context 'not showing admin only' do
        its(:num_pages) { should eq 2 }
      end
    end
  end

  describe '#response_fields_for_page' do
    before { form.save }

    context 'with 2 pages' do
      let!(:rf1) { form.response_fields.create(type: 'Formbuilder::ResponseFieldText', label: 'foo') }
      let!(:rf2) { form.response_fields.create(type: 'Formbuilder::ResponseFieldPageBreak') }
      let!(:rf3) { form.response_fields.create(type: 'Formbuilder::ResponseFieldParagraph', label: 'foo2') }

      it 'calculates properly' do
        expect(form.response_fields_for_page(1)).to eq [rf1]
        expect(form.response_fields_for_page(2)).to eq [rf3]
      end
    end
  end

end
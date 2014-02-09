require 'spec_helper'

describe Formbuilder::ResponseFieldFile do

  let!(:form) { Formbuilder::Form.create }
  let!(:response_field) { Formbuilder::ResponseFieldFile.create(form: form) }
  let!(:entry) { Entry.create(form: form) }

  let(:file_value) { File.open(File.expand_path('../../fixtures/test_files/text2.txt', File.dirname(__FILE__))) }

  subject { response_field }
  subject(:rf) { response_field }

  describe '#audit_response' do
    it 'adds the filename param' do
      entry.save_response([file_value], rf)
      entry.audit_responses
      entry.responses["#{rf.id}_filename"].should == 'text2.txt'
    end
  end

  describe '#sortable_value' do
    it 'calculates properly' do
      entry.save_response([file_value], rf)
      entry.responses["#{rf.id}_sortable_value"].should == 1
    end
  end

  describe '#transform_raw_value' do
    it 'preserves old upload' do
      entry.save_response([file_value], rf)
      initial_attachment = rf.get_attachments(entry.responses[rf.id.to_s]).first
      entry.save_response([], rf)
      initial_attachment.reload.should be_present
    end

    it 'removes old upload when setting a new one' do
      entry.save_response([file_value], rf)
      initial_attachment = rf.get_attachments(entry.responses[rf.id.to_s]).first
      entry.save_response([file_value], rf)
      expect { initial_attachment.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'uploads multiple files' do
      expect {
        entry.save_response([file_value, file_value], rf)
      }.to change { Formbuilder::EntryAttachment.count }.by(2)

      rf.get_attachments(entry.responses[rf.id.to_s]).length.should == 2
    end

    it 'does not choke on nil values' do
      expect {
        entry.save_response([nil], rf)
      }.to_not change { Formbuilder::EntryAttachment.count }
    end
  end

  describe '#render_entry' do
    before do
      entry.save_response([file_value], rf)
    end

    it 'renders properly' do
      rf.render_entry(entry.responses[rf.id.to_s]).should match 'text2.txt'
    end
  end

  describe '#render_entry_text' do
    before do
      entry.save_response([file_value], rf)
    end

    it 'renders properly' do
      rf.render_entry_text(entry.responses[rf.id.to_s]).should match 'text2.txt'
      rf.render_entry_text(entry.responses[rf.id.to_s]).should_not match '<'
    end
  end

end

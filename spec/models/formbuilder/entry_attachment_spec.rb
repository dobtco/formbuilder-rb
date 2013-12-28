require 'spec_helper'

describe Formbuilder::EntryAttachment do

  let!(:model) { Formbuilder::EntryAttachment.new }

  it 'saves the content type and file size' do
    model.upload = File.open(File.join(Formbuilder.root, 'spec/fixtures/test_files/text.txt'))
    model.save
    model.upload.should be_present
    model.file_size.should == 8
    model.content_type.should == 'text/plain'
    model.update_attributes(remove_upload: true)
    model.upload.should_not be_present
  end

end
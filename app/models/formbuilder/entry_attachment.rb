module Formbuilder
  class EntryAttachment < ActiveRecord::Base

    mount_uploader :upload, Formbuilder::EntryAttachmentUploader

  end
end

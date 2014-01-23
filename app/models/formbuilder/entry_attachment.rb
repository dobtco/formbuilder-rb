module Formbuilder
  class EntryAttachment < ActiveRecord::Base

    mount_uploader :upload, Formbuilder::EntryAttachmentUploader

    validates :upload, presence: true

  end
end

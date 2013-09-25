module Formbuilder
  class EntryAttachment < ActiveRecord::Base

    mount_uploader :upload, Formbuilder::EntryAttachmentUploader
    before_save :update_upload_attributes

    private
    def update_upload_attributes
      if upload.present? && upload_changed?
        self.content_type = upload.file.content_type
      end
    end

  end
end
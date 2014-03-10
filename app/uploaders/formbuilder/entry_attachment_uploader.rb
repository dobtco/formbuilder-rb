require 'carrierwave/processing/mime_types'

module Formbuilder
  class EntryAttachmentUploader < ::BaseUploader
    include CarrierWave::MimeTypes
    include CarrierWave::RMagick

    process :set_content_type
    process :save_content_type_and_size_in_model

    version :thumb, :if => :image? do
      process resize_to_limit: [250, 250]
    end

    protected
    def image?(file)
      content_type = file.try(:content_type) || model.try(:content_type)
      content_type && content_type.include?('image')
    end

    def save_content_type_and_size_in_model
      model.content_type = file.try(:content_type)
      model.file_size = file.try(:size)
    end
  end
end

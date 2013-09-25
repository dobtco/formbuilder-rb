require 'carrierwave/processing/mime_types'

module Formbuilder
  class EntryAttachmentUploader < CarrierWave::Uploader::Base
    include CarrierWave::MimeTypes
    include CarrierWave::RMagick

    process :set_content_type

    version :thumb, :if => :image? do
      process resize_to_limit: [250, 250]
    end

    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    protected
    def image?(file)
      content_type = file.content_type || model.try(:content_type)
      content_type && content_type.include?('image')
    end
  end
end

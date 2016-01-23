require 'carrierwave/processing/mime_types'

module Formbuilder
  class EntryAttachmentUploader < CarrierWave::Uploader::Base
    include CarrierWave::MimeTypes
    include CarrierWave::RMagick

    # Use file storage if Test Environment
    storage_mechanism = Rails.env.test? ? :file : :fog
    storage storage_mechanism

    process :set_content_type
    process :save_content_type_and_size_in_model

    version :thumb, :if => :image? do
      process resize_to_limit: [250, 250]
    end

    # Set to nil if no file path required
    #
    # @return [String]
    def store_dir
      Digest::SHA2.hexdigest("#{model.class.to_s.underscore}-#{mounted_as}-#{model.id.to_s}").first(32)
    end

    # Filename
    #
    # @return [String]
    def raw_filename
      model.read_attribute(:upload)
    end

    protected

    # Is content-type image?
    #
    # @return [Boolean]
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

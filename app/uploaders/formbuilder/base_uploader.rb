module Formbuilder
  class BaseUploader < CarrierWave::Uploader::Base
    @fog_public = false

    def store_dir
      digest = Digest::SHA2.hexdigest("#{model.class.to_s.underscore}-#{mounted_as}-#{model.id.to_s}").first(32)
      "uploads/#{digest}"
    end

    def raw_filename
      @model.read_attribute(:upload)
    end
  end
end

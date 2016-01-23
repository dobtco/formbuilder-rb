require 'yaml'
require 'carrierwave'
require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

# Don't be a dummy and follow the incorrect docs for hours like I did!
# DOCS on github home are for master!
# DOCS FOR v0.10.0 can be found here:
# https://github.com/carrierwaveuploader/carrierwave/tree/v0.10.0
CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id:     Rails.application.secrets.ec2_access_key,
    aws_secret_access_key: Rails.application.secrets.ec2_access_secret,
    region:                Rails.application.secrets.buccaneer_region
  }

  # Bucket Name
  config.fog_directory = Rails.application.secrets.buccaneer_bucket
  config.fog_public = false
  config.fog_use_ssl_for_aws = true
  config.cache_dir = Rails.root.join('tmp', 'uploads')
end

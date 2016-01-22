require 'yaml'
require 'carrierwave'
require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

S3 = YAML.load_file(Rails.root.join('config', 's3.yml'))[Rails.env]

# Don't be a dummy and follow the incorrect docs for hours like I did!
# DOCS on github home are for master!
# DOCS FOR v0.10.0 can be found here:
# https://github.com/carrierwaveuploader/carrierwave/tree/v0.10.0
CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id:     S3['access_key'],
    aws_secret_access_key: S3['secret_key'],
    region:                S3['region']
  }

  # Bucket Name
  config.fog_directory = S3['bucket']
  config.fog_public = false
  config.fog_use_ssl_for_aws = true
  config.cache_dir = Rails.root.join('tmp', 'uploads')
end

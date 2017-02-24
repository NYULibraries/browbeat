module Browbeat
  module AWS
    module S3
      class ScreenshotManager
        def self.key_prefix
          @key_prefix ||= "screenshots/#{Time.now.year}/#{Time.now.month}/#{Time.now.day}/"
        end

        def self.base_public_url
          @base_public_url ||= "https://#{ENV['AWS_S3_BUCKET_NAME']}.s3.amazonaws.com/#{key_prefix}"
        end
      end
    end
  end
end

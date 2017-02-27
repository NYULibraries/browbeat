require 'spec_helper'
require 'browbeat'

describe Browbeat::AWS::S3::ScreenshotManager do
  describe "self.key_prefix" do
    subject{ described_class.key_prefix }
    let(:time){ Time.new(2012,12,22) }
    before { allow(Time).to receive(:now).and_return time }

    it { is_expected.to eq "screenshots/2012/12/22/" }
  end

  describe "self.base_public_url" do
    subject{ described_class.base_public_url }
    let(:key_prefix){ "screenshots/2024/8/15/" }
    let(:s3_bucket_name){ "some-bucket" }
    before { allow(described_class).to receive(:key_prefix).and_return key_prefix }
    around do |example|
      with_modified_env AWS_S3_BUCKET_NAME: s3_bucket_name do
        example.run
      end
    end

    it { is_expected.to eq "https://some-bucket.s3.amazonaws.com/screenshots/2024/8/15/" }
  end
end

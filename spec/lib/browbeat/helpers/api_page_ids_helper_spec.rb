require 'spec_helper'
require 'browbeat'

describe Browbeat::Helpers::ApiPageIdsHelper do
  let(:helper){ Class.new{ extend Browbeat::Helpers::ApiPageIdsHelper } }

  describe "status_page_page_id" do
    subject{ helper.status_page_page_id }

    around do |example|
      with_modified_env STATUS_PAGE_PAGE_ID: page_id do
        example.run
      end
    end

    context "with STATUS_PAGE_PAGE_ID" do
      let(:page_id){ "abcd" }

      it { is_expected.to eq "abcd" }
    end

    context "without STATUS_PAGE_PAGE_ID" do
      let(:page_id){ nil }

      it "should raise error" do
        expect{ subject }.to raise_error "Must specify STATUS_PAGE_PAGE_ID"
      end
    end
  end

  describe "status_page_staging_page_id" do
    subject{ helper.status_page_staging_page_id }

    around do |example|
      with_modified_env STATUS_PAGE_STAGING_PAGE_ID: page_id do
        example.run
      end
    end

    context "with STATUS_PAGE_STAGING_PAGE_ID" do
      let(:page_id){ "abcd" }

      it { is_expected.to eq "abcd" }
    end

    context "without STATUS_PAGE_STAGING_PAGE_ID" do
      let(:page_id){ nil }

      it "should raise error" do
        expect{ subject }.to raise_error "Must specify STATUS_PAGE_STAGING_PAGE_ID"
      end
    end
  end

end

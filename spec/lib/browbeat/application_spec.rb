require 'spec_helper'
require 'browbeat'

describe Browbeat::Application do
  # describe "class methods" do
  #   describe "self.list_all" do
  #     subject{ described_class.list_all }
  #     
  #
  #   end
  # end

  describe "instance methods" do
    let(:name){ "Login" }
    let(:status_page_production_id){ "abcd1234" }
    let(:status_page_staging_id){ "zyxw9876" }
    let(:symbol){ "login" }
    let(:application){ described_class.new(name: name, status_page_production_id: status_page_production_id, status_page_staging_id: status_page_staging_id, symbol: symbol) }

    describe "set_status_page_status" do
      let(:component){ instance_double StatusPage::API::Component, save: true, :"status=" => true }

      context "with no environment specified" do
        subject { application.set_status_page_status "some_status" }
        before { allow(application).to receive(:status_page_production_component).and_return component }

        it "should set component status and save with correct parameters" do
          expect(component).to receive(:status=).with("some_status").ordered
          expect(component).to receive(:save).ordered
          subject
        end
      end

      context "with environment: :staging" do
        subject { application.set_status_page_status "some_status", environment: :staging }
        before { allow(application).to receive(:status_page_staging_component).and_return component }

        it "should set component status and save with correct parameters" do
          expect(component).to receive(:status=).with("some_status").ordered
          expect(component).to receive(:save).ordered
          subject
        end
      end

      context "with environment: :production" do
        subject { application.set_status_page_status "some_status", environment: :production }
        before { allow(application).to receive(:status_page_production_component).and_return component }

        it "should set component status and save with correct parameters" do
          expect(component).to receive(:status=).with("some_status").ordered
          expect(component).to receive(:save).ordered
          subject
        end
      end
    end

    describe "status_page_production_component" do
      subject { application.status_page_production_component }
      let(:component){ instance_double StatusPage::API::Component, get: true }
      before { allow(StatusPage::API::Component).to receive(:new).and_return component }
      around do |example|
        with_modified_env STATUS_PAGE_PAGE_ID: page_id do
          example.run
        end
      end

      context "with STATUS_PAGE_PAGE_ID set" do
        let(:page_id){ "xxxx" }

        it { is_expected.to eq component }

        it "should call initialize with correct params" do
          expect(StatusPage::API::Component).to receive(:new).with(status_page_production_id, "xxxx")
          subject
        end

        it "should call get" do
          expect(component).to receive(:get)
          subject
        end
      end

      context "without STATUS_PAGE_PAGE_ID set" do
        let(:page_id){ nil }

        it "should raise an error" do
          expect{ subject }.to raise_error "Must specify STATUS_PAGE_PAGE_ID"
        end
      end
    end

    describe "status_page_staging_component" do
      subject { application.status_page_staging_component }
      let(:component){ instance_double StatusPage::API::Component, get: true }
      before { allow(StatusPage::API::Component).to receive(:new).and_return component }
      around do |example|
        with_modified_env STATUS_PAGE_STAGING_PAGE_ID: page_id do
          example.run
        end
      end

      context "with STATUS_PAGE_STAGING_PAGE_ID set" do
        let(:page_id){ "xxxx" }

        it { is_expected.to eq component }

        it "should call initialize with correct params" do
          expect(StatusPage::API::Component).to receive(:new).with(status_page_staging_id, "xxxx")
          subject
        end

        it "should call get" do
          expect(component).to receive(:get)
          subject
        end
      end

      context "without STATUS_PAGE_STAGING_PAGE_ID set" do
        let(:page_id){ nil }

        it "should raise an error" do
          expect{ subject }.to raise_error "Must specify STATUS_PAGE_STAGING_PAGE_ID"
        end
      end
    end


  end
end

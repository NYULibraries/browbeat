require 'spec_helper'
require 'browbeat'

describe Browbeat::Helpers::StatusPagePresenterHelper do
  # create helper class with environments accessor (a requirement for helper)
  let(:helper_class) do
    Class.new do
      include Browbeat::Helpers::StatusPagePresenterHelper

      attr_accessor :environments

      def initialize(environments)
        @environments = environments
      end
    end
  end
  let(:helper){ helper_class.new environments }
  let(:environments){ %w[production staging] }

  describe "failing_on_status_page?" do
    subject { helper.failing_on_status_page?(application) }
    let(:application){ instance_double Browbeat::Application }

    context "failing on production" do
      before { allow(helper).to receive(:failing_on_production?).with(application).and_return true }

      context "failing on staging" do
        before { allow(helper).to receive(:failing_on_staging?).with(application).and_return true }

        it { is_expected.to be_truthy }
      end

      context "not failing on staging" do
        before { allow(helper).to receive(:failing_on_staging?).with(application).and_return false }

        it { is_expected.to be_truthy }
      end
    end

    context "not failing on production" do
      before { allow(helper).to receive(:failing_on_production?).with(application).and_return false }

      context "failing on staging" do
        before { allow(helper).to receive(:failing_on_staging?).with(application).and_return true }

        it { is_expected.to be_truthy }
      end

      context "not failing on staging" do
        before { allow(helper).to receive(:failing_on_staging?).with(application).and_return false }

        it { is_expected.to be_falsy }
      end
    end

  end

  describe "failing_on_production?" do
    subject { helper.failing_on_production?(application) }
    let(:status_page_production_id){ "abcd" }
    let(:application){ instance_double Browbeat::Application, status_page_production_component: component }
    let(:component){ instance_double StatusPage::API::Component, failing?: true }

    context "with all environments" do
      it { is_expected.to eq true }

      it "should call failing? correctly" do
        expect(component).to receive(:failing?)
        subject
      end
    end

    context "with only staging environment" do
      let(:environments){ %w[staging] }

      it { is_expected.to eq false }
    end
  end

  describe "failing_on_staging?" do
    subject { helper.failing_on_staging?(application) }
    let(:status_page_staging_id){ "xyzw" }
    let(:application){ instance_double Browbeat::Application, status_page_staging_component: component }
    let(:component){ instance_double StatusPage::API::Component, failing?: true }

    context "with all environments" do
      it { is_expected.to eq true }

      it "should call failing? correctly" do
        expect(component).to receive(:failing?)
        subject
      end
    end

    context "with only production environment" do
      let(:environments){ %w[production] }

      it { is_expected.to eq false }
    end
  end
end

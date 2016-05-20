require 'spec_helper'
require 'failure_tracker'

describe FailureTracker::StatusSync do
  describe "class methods" do
    describe "self.sync_status_page" do
      subject{ described_class.sync_status_page collection }
      let(:collection){ double FailureTracker::ScenarioCollection }
      let(:instance){ double described_class, sync_status_page: true }
      before { allow(described_class).to receive(:new).and_return instance }

      it "should call new with given collection" do
        expect(described_class).to receive(:new).with(collection)
        subject
      end

      it "should call sync_status_page on new instance" do
        expect(instance).to receive(:sync_status_page)
        subject
      end
    end
  end

  describe "instance methods" do
    let(:collection){ double FailureTracker::ScenarioCollection }
    let(:new_collection){ double FailureTracker::ScenarioCollection }
    let(:instance){ described_class.new collection }

    describe "sync_status_page" do
      subject{ instance.sync_status_page }
      let(:application1){ double FailureTracker::Application, set_status_page_status: true }
      let(:application2){ double FailureTracker::Application, set_status_page_status: true }
      let(:application3){ double FailureTracker::Application, set_status_page_status: true }
      let(:application4){ double FailureTracker::Application, set_status_page_status: true }
      let(:status1){ 'operational' }
      let(:status3){ 'major_outage' }
      let(:status4){ 'degraded_performance' }
      before do
        allow(FailureTracker::Application).to receive(:list_all).and_return [application1, application2, application3, application4]
        allow(instance).to receive(:scenarios_for_application?).and_return true, false, true, true
        allow(instance).to receive(:status_for_application).and_return status1, status3, status4
      end

      it "should call scenarios_for_application? with each application" do
        expect(instance).to receive(:scenarios_for_application?).with(application1)
        expect(instance).to receive(:scenarios_for_application?).with(application2)
        expect(instance).to receive(:scenarios_for_application?).with(application3)
        expect(instance).to receive(:scenarios_for_application?).with(application4)
        subject
      end

      it "should call status_for_application with each application for which scenarios_for_application? returns true" do
        expect(instance).to receive(:status_for_application).with(application1)
        expect(instance).to_not receive(:status_for_application).with(application2)
        expect(instance).to receive(:status_for_application).with(application3)
        expect(instance).to receive(:status_for_application).with(application4)
        subject
      end

      it "should call set_status_page_status on each application for which scenarios_for_application? returns true" do
        expect(application1).to receive(:set_status_page_status).with(status1)
        expect(application2).to_not receive(:set_status_page_status)
        expect(application3).to receive(:set_status_page_status).with(status3)
        expect(application4).to receive(:set_status_page_status).with(status4)
        subject
      end
    end

    describe "status_for_application" do
      subject{ instance.status_for_application application }
      let(:application){ double FailureTracker::Application }
      before do
        allow(instance).to receive(:failed_scenarios_for_application).and_return new_collection
      end

      context "with application failures" do
        let(:failure){ 'failure' }
        before do
          allow(new_collection).to receive(:any?).and_return true
          allow(new_collection).to receive(:worst_failure_type).and_return failure
        end

        it { is_expected.to eq failure }

        it "should call failed_scenarios_for_application" do
          expect(instance).to receive(:failed_scenarios_for_application).with(application)
          subject
        end

        it "should call any?" do
          expect(new_collection).to receive(:any?)
          subject
        end

        it "should call worst_failure_type" do
          expect(new_collection).to receive(:worst_failure_type)
          subject
        end
      end

      context "without application failures" do
        before { allow(new_collection).to receive(:any?).and_return false }

        it { is_expected.to eq "operational" }

        it "should call failed_scenarios_for_application" do
          expect(instance).to receive(:failed_scenarios_for_application).with(application)
          subject
        end

        it "should call any?" do
          expect(new_collection).to receive(:any?)
          subject
        end

        it "should not call worst_failure_type" do
          expect(new_collection).to_not receive(:worst_failure_type)
          subject
        end
      end
    end

    describe "failed_scenarios_for_application" do
      subject{ instance.failed_scenarios_for_application application }
      let(:application){ double FailureTracker::Application, symbol: "wxyz" }
      let(:scenario1){ double FailureTracker::Scenario, app_symbol: "wxyz", failed?: false }
      let(:scenario2){ double FailureTracker::Scenario, app_symbol: "wxyz", failed?: true }
      let(:scenario3){ double FailureTracker::Scenario, app_symbol: "abcd", failed?: false }
      let(:scenario4){ double FailureTracker::Scenario, app_symbol: "wxyz", failed?: true }
      let(:scenario5){ double FailureTracker::Scenario, app_symbol: "abcd", failed?: true }
      let(:scenario6){ double FailureTracker::Scenario, app_symbol: "wxyz", failed?: true }
      let(:collection){ FailureTracker::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4, scenario5, scenario6] }
      # stub out has_tags? only for production
      before do
        allow(scenario1).to receive(:has_tags?).with(:production).and_return true
        allow(scenario2).to receive(:has_tags?).with(:production).and_return true
        allow(scenario3).to receive(:has_tags?).with(:production).and_return true
        allow(scenario4).to receive(:has_tags?).with(:production).and_return true
        allow(scenario5).to receive(:has_tags?).with(:production).and_return true
        allow(scenario6).to receive(:has_tags?).with(:production).and_return false
      end

      it { is_expected.to be_a FailureTracker::ScenarioCollection }
      it { is_expected.to match_array [scenario2, scenario4] }
    end
  end
end

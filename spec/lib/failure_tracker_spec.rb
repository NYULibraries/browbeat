require 'spec_helper'
require 'failure_tracker'

describe FailureTracker do
  describe "failures"

  describe "register_failure" do
    let(:scenario){ double Cucumber::Ast::Scenario }

    context "initial call" do
      subject{ FailureTracker.register_failure scenario }

      it "should add failure to collection" do
        subject
        expect(FailureTracker.failures.to_a.map(&:cucumber_scenario)).to include scenario
      end
    end

    context "successive calls" do
      subject do
        FailureTracker.register_failure scenario
        FailureTracker.register_failure scenario2
        FailureTracker.register_failure scenario3
      end
      let(:scenario2){ double FailureTracker::FailedScenario }
      let(:scenario3){ double FailureTracker::FailedScenario }

      it "should retain all failures in collection" do
        subject
        expect(FailureTracker.failures.to_a.map(&:cucumber_scenario)).to include scenario
        expect(FailureTracker.failures.to_a.map(&:cucumber_scenario)).to include scenario2
        expect(FailureTracker.failures.to_a.map(&:cucumber_scenario)).to include scenario3
      end
    end
  end

  describe "sync_status_page" do
    subject{ FailureTracker.sync_status_page }
    let(:collection){ FailureTracker::FailedScenarioCollection }
    before do
      allow(FailureTracker).to receive(:failures).and_return collection
      allow(FailureTracker::StatusSync).to receive(:sync_status_page)
    end

    it "should call failures" do
      expect(FailureTracker).to receive(:failures)
      subject
    end

    it "should call sync_status_page with failures" do
      expect(FailureTracker::StatusSync).to receive(:sync_status_page).with(collection)
      subject
    end
  end
end

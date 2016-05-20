require 'spec_helper'
require 'failure_tracker'

describe FailureTracker do
  describe "scenarios"

  describe "register_scenario" do
    let(:scenario){ double Cucumber::Ast::Scenario }

    context "initial call" do
      subject{ FailureTracker.register_scenario scenario }

      it "should add scenario to collection" do
        subject
        expect(FailureTracker.scenarios.to_a.map(&:cucumber_scenario)).to include scenario
      end
    end

    context "successive calls" do
      subject do
        FailureTracker.register_scenario scenario
        FailureTracker.register_scenario scenario2
        FailureTracker.register_scenario scenario3
      end
      let(:scenario2){ double FailureTracker::Scenario }
      let(:scenario3){ double FailureTracker::Scenario }

      it "should retain all scenarios in collection" do
        subject
        expect(FailureTracker.scenarios.to_a.map(&:cucumber_scenario)).to include scenario
        expect(FailureTracker.scenarios.to_a.map(&:cucumber_scenario)).to include scenario2
        expect(FailureTracker.scenarios.to_a.map(&:cucumber_scenario)).to include scenario3
      end
    end
  end

  describe "sync_status_page" do
    subject{ FailureTracker.sync_status_page }
    let(:collection){ FailureTracker::ScenarioCollection }
    before do
      allow(FailureTracker).to receive(:scenarios).and_return collection
      allow(FailureTracker::StatusSync).to receive(:sync_status_page)
    end

    it "should call scenarios" do
      expect(FailureTracker).to receive(:scenarios)
      subject
    end

    it "should call sync_status_page with scenarios" do
      expect(FailureTracker::StatusSync).to receive(:sync_status_page).with(collection)
      subject
    end
  end

  describe "send_status_mail" do
    subject{ FailureTracker.send_status_mail }
    let(:collection){ FailureTracker::ScenarioCollection }
    before do
      allow(FailureTracker).to receive(:scenarios).and_return collection
      allow(FailureTracker::StatusMailer).to receive(:send_status)
    end

    it "should call scenarios" do
      expect(FailureTracker).to receive(:scenarios)
      subject
    end

    it "should call sync_status_page with scenarios" do
      expect(FailureTracker::StatusMailer).to receive(:send_status).with(collection)
      subject
    end
  end
end

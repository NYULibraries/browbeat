require 'spec_helper'
require 'browbeat'

describe Browbeat::FailureTracker do
  let(:tracker){ described_class.new }

  describe "scenarios"

  describe "register_scenario" do
    let(:scenario){ double Cucumber::Ast::Scenario }

    context "initial call" do
      subject{ tracker.register_scenario scenario }

      it "should add scenario to collection" do
        subject
        expect(tracker.scenarios.to_a.map(&:cucumber_scenario)).to include scenario
      end
    end

    context "successive calls" do
      subject do
        tracker.register_scenario scenario
        tracker.register_scenario scenario2
        tracker.register_scenario scenario3
      end
      let(:scenario2){ double Browbeat::Scenario }
      let(:scenario3){ double Browbeat::Scenario }

      it "should retain all scenarios in collection" do
        subject
        expect(tracker.scenarios.to_a.map(&:cucumber_scenario)).to include scenario
        expect(tracker.scenarios.to_a.map(&:cucumber_scenario)).to include scenario2
        expect(tracker.scenarios.to_a.map(&:cucumber_scenario)).to include scenario3
      end
    end
  end

  describe "sync_status_page" do
    subject{ tracker.sync_status_page }
    let(:collection){ Browbeat::ScenarioCollection }
    before do
      allow(tracker).to receive(:scenarios).and_return collection
      allow(Browbeat::StatusSync).to receive(:sync_status_page)
    end

    it "should call scenarios" do
      expect(tracker).to receive(:scenarios)
      subject
    end

    it "should call sync_status_page with scenarios" do
      expect(Browbeat::StatusSync).to receive(:sync_status_page).with(collection)
      subject
    end
  end

  describe "send_status_mail" do
    subject{ tracker.send_status_mail }
    let(:collection){ Browbeat::ScenarioCollection }
    before do
      allow(tracker).to receive(:scenarios).and_return collection
      allow(Browbeat::StatusMailer).to receive(:send_status)
    end

    it "should call scenarios" do
      expect(tracker).to receive(:scenarios)
      subject
    end

    it "should call sync_status_page with scenarios" do
      expect(Browbeat::StatusMailer).to receive(:send_status).with(collection)
      subject
    end
  end
end

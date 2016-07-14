require 'spec_helper'
require 'browbeat'

describe Browbeat::FailureTracker do
  let(:tracker){ described_class.new }

  describe "register_scenario" do
    let(:scenario){ instance_double Cucumber::Ast::Scenario }

    context "initial call" do
      subject{ tracker.register_scenario scenario }

      it "should add scenario to scenario_collection" do
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
      let(:scenario2){ instance_double Browbeat::Scenario }
      let(:scenario3){ instance_double Browbeat::Scenario }

      it "should retain all scenarios in scenario_collection" do
        subject
        expect(tracker.scenarios.to_a.map(&:cucumber_scenario)).to include scenario
        expect(tracker.scenarios.to_a.map(&:cucumber_scenario)).to include scenario2
        expect(tracker.scenarios.to_a.map(&:cucumber_scenario)).to include scenario3
      end
    end
  end

  describe "sync_status_page" do
    subject{ tracker.sync_status_page }
    let(:scenario_collection){ instance_double Browbeat::ScenarioCollection }
    let(:application_collection){ instance_double Browbeat::ApplicationCollection }
    before do
      allow_any_instance_of(Browbeat::ApplicationCollection).to receive(:load_yml).and_return application_collection
      allow(tracker).to receive(:scenarios).and_return scenario_collection
      allow(Browbeat::StatusSync).to receive(:sync_status_page)
    end

    it "should call scenarios" do
      expect(tracker).to receive(:scenarios)
      subject
    end

    it "should call sync_status_page with scenarios" do
      expect(Browbeat::StatusSync).to receive(:sync_status_page).with(scenario_collection, application_collection)
      subject
    end
  end

  describe "send_status_mail" do
    subject{ tracker.send_status_mail }
    let(:scenario_collection){ instance_double Browbeat::ScenarioCollection }
    let(:application_collection){ instance_double Browbeat::ApplicationCollection }
    before do
      allow_any_instance_of(Browbeat::ApplicationCollection).to receive(:load_yml).and_return application_collection
      allow(tracker).to receive(:scenarios).and_return scenario_collection
      allow(Browbeat::StatusMailer).to receive(:send_status)
    end

    it "should call scenarios" do
      expect(tracker).to receive(:scenarios)
      subject
    end

    it "should call sync_status_page with scenarios" do
      expect(Browbeat::StatusMailer).to receive(:send_status).with(scenario_collection, application_collection)
      subject
    end
  end
end

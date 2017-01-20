require 'spec_helper'
require 'browbeat'

describe Browbeat::FailureTracker do
  let(:tracker){ described_class.new }
  let(:application_collection){ instance_double Browbeat::ApplicationCollection, load_yml: partially_populated_application_collection }
  let(:partially_populated_application_collection){ instance_double Browbeat::ApplicationCollection, load_components: populated_application_collection }
  let(:populated_application_collection){ instance_double Browbeat::ApplicationCollection }
  before do
    allow(Browbeat::ApplicationCollection).to receive(:new).and_return application_collection
  end

  describe "initialize" do
    it "should call load_yml" do
      expect(application_collection).to receive(:load_yml)
      tracker
    end

    it "should call load_components" do
      expect(partially_populated_application_collection).to receive(:load_components)
      tracker
    end
  end

  describe "register_scenario" do
    let(:scenario){ instance_double Cucumber::Core::Test::Case }

    context "initial call" do
      subject{ tracker.register_scenario scenario }

      it "should add scenario to scenario_collection" do
        subject
        expect(tracker.scenarios.to_a.map(&:cucumber_scenario)).to include scenario
      end

      context "with steps" do
        let(:step_event1){ instance_double Browbeat::StepEvent }
        let(:step_event2){ instance_double Browbeat::StepEvent }
        before do
          tracker.step_events << step_event1
          tracker.step_events << step_event2
          expect(tracker.step_events.length).to eq 2
        end

        it "should initialize scenario with steps" do
          subject
          expect(tracker.scenarios[-1].step_events).to include step_event1
          expect(tracker.scenarios[-1].step_events).to include step_event2
        end
        it "should clear out steps" do
          subject
          expect(tracker.step_events).to eq []
        end
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

  describe "register_after_test_step" do
    subject{ tracker.register_after_test_step(cucumber_event) }
    let(:cucumber_event){ instance_double Cucumber::Events::AfterTestStep }
    let(:step_event){ instance_double Browbeat::StepEvent, scenario_step?: scenario_step }
    before do
      allow(Browbeat::StepEvent).to receive(:new).and_return step_event
    end

    context "if scenario_step? returns true" do
      let(:scenario_step){ true }

      it "should add step to array" do
        subject
        expect(tracker.step_events).to include step_event
      end
      it "should initialize step event properly" do
        expect(Browbeat::StepEvent).to receive(:new).with(cucumber_event)
        subject
      end
    end

    context "if scenario_step? returns false" do
      let(:scenario_step){ false }

      it "should not add step to array" do
        subject
        expect(tracker.step_events).to_not include step_event
      end
      it "should initialize step event properly" do
        expect(Browbeat::StepEvent).to receive(:new).with(cucumber_event)
        subject
      end
    end
  end

  describe "sync_status_page" do
    subject{ tracker.sync_status_page }
    let(:scenario_collection){ instance_double Browbeat::ScenarioCollection }
    before do
      allow(tracker).to receive(:scenarios).and_return scenario_collection
      allow(Browbeat::StatusSync).to receive(:sync_status_page)
    end

    it "should call scenarios" do
      expect(tracker).to receive(:scenarios)
      subject
    end

    it "should call sync_status_page with scenarios" do
      expect(Browbeat::StatusSync).to receive(:sync_status_page).with(scenario_collection, populated_application_collection)
      subject
    end
  end

  describe "send_status_mail" do
    subject{ tracker.send_status_mail }
    let(:scenario_collection){ instance_double Browbeat::ScenarioCollection }
    before do
      allow(tracker).to receive(:scenarios).and_return scenario_collection
      allow(Browbeat::StatusMailer).to receive(:send_status)
    end

    it "should call scenarios" do
      expect(tracker).to receive(:scenarios)
      subject
    end

    it "should call sync_status_page with scenarios" do
      expect(Browbeat::StatusMailer).to receive(:send_status).with(scenario_collection, populated_application_collection)
      subject
    end
  end
end

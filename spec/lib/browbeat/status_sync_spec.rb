require 'spec_helper'
require 'browbeat'

describe Browbeat::StatusSync do
  describe "class methods" do
    describe "self.sync_status_page" do
      subject{ described_class.sync_status_page scenario_collection, application_collection }
      let(:scenario_collection){ instance_double Browbeat::ScenarioCollection }
      let(:application_collection){ instance_double Browbeat::ApplicationCollection }
      let(:instance){ instance_double described_class, sync_status_page: true }
      before do
        allow(described_class).to receive(:new).and_return instance
      end

      it "should call new with given scenario_collection" do
        expect(described_class).to receive(:new).with(scenario_collection, application_collection)
        subject
      end

      it "should call sync_status_page on new instance" do
        expect(instance).to receive(:sync_status_page)
        subject
      end

      it "should call get_failing_components before initializing" do
        expect(described_class).to receive(:new).ordered
        subject
      end
    end
  end

  describe "instance methods" do
    let(:scenario_collection){ instance_double Browbeat::ScenarioCollection }
    let(:new_scenario_collection){ instance_double Browbeat::ScenarioCollection }
    let(:application_collection){ instance_double Browbeat::ApplicationCollection }
    let(:instance){ described_class.new scenario_collection, application_collection }

    describe "sync_status_page" do
      subject{ instance.sync_status_page }
      let(:application1){ instance_double Browbeat::Application, set_status_page_status: true }
      let(:application2){ instance_double Browbeat::Application, set_status_page_status: true }
      let(:application3){ instance_double Browbeat::Application, set_status_page_status: true }
      let(:application4){ instance_double Browbeat::Application, set_status_page_status: true }
      let(:status_production1){ 'operational' }
      let(:status_staging1){ 'partial_outage' }
      let(:status_production3){ 'major_outage' }
      let(:status_staging4){ 'degraded_performance' }
      let(:application_collection){ Browbeat::ApplicationCollection.new(applications) }
      let(:applications){ [application1, application2, application3, application4] }
      before do
        # no scenarios exist for application2
        allow(instance).to receive(:scenarios_for_application?).and_return true, false, true, true
        # no stagings scenarios for application3, nor production scenarios for application4
        allow(instance).to receive(:tagged_scenarios_for_application?).and_return true, true, true, false, false, true
        allow(instance).to receive(:status_for_application).and_return status_production1, status_staging1, status_production3, status_staging4
        allow(instance).to receive(:sleep)
      end

      it "should call scenarios_for_application? with each application" do
        expect(instance).to receive(:scenarios_for_application?).with(application1)
        expect(instance).to receive(:scenarios_for_application?).with(application2)
        expect(instance).to receive(:scenarios_for_application?).with(application3)
        expect(instance).to receive(:scenarios_for_application?).with(application4)
        subject
      end

      it "should call tagged_scenarios_for_application? with each environment type and application for which scenarios_for_application? returns true" do
        expect(instance).to receive(:tagged_scenarios_for_application?).with(application1, :production)
        expect(instance).to receive(:tagged_scenarios_for_application?).with(application1, :staging)
        expect(instance).to_not receive(:tagged_scenarios_for_application?).with(application2, :production)
        expect(instance).to_not receive(:tagged_scenarios_for_application?).with(application2, :staging)
        expect(instance).to receive(:tagged_scenarios_for_application?).with(application3, :production)
        expect(instance).to receive(:tagged_scenarios_for_application?).with(application3, :staging)
        expect(instance).to receive(:tagged_scenarios_for_application?).with(application4, :production)
        expect(instance).to receive(:tagged_scenarios_for_application?).with(application4, :staging)
        subject
      end

      it "should call status_for_application with each application for which tagged_scenarios_for_application? returns true" do
        expect(instance).to receive(:status_for_application).with(application1, :production)
        expect(instance).to receive(:status_for_application).with(application1, :staging)
        expect(instance).to_not receive(:status_for_application).with(application2, :production)
        expect(instance).to_not receive(:status_for_application).with(application2, :staging)
        expect(instance).to receive(:status_for_application).with(application3, :production)
        expect(instance).to_not receive(:status_for_application).with(application3, :staging)
        expect(instance).to_not receive(:status_for_application).with(application4, :production)
        expect(instance).to receive(:status_for_application).with(application4, :staging)
        subject
      end

      it "should call set_status_page_status on each application for which scenarios_for_application? returns true" do
        expect(application1).to receive(:set_status_page_status).once.with(status_production1)
        expect(application1).to receive(:set_status_page_status).once.with(status_staging1, environment: :staging)
        expect(application2).to_not receive(:set_status_page_status)
        expect(application3).to receive(:set_status_page_status).once.with(status_production3)
        expect(application4).to receive(:set_status_page_status).once.with(status_staging4, environment: :staging)
        subject
      end

      it "should call sleep for each application-environment with scenarios" do
        expect(instance).to receive(:sleep).exactly(4).times
        subject
      end
    end

    describe "status_for_application" do
      subject{ instance.status_for_application(application, :production) }
      let(:application){ instance_double Browbeat::Application }
      before do
        allow(instance).to receive(:failed_tagged_scenarios_for_application).and_return new_scenario_collection
      end

      context "with application failures" do
        context "with valid failures" do
          let(:failure){ 'major_outage' }
          before do
            allow(new_scenario_collection).to receive(:worst_failure_type).and_return failure
          end

          it { is_expected.to eq failure }

          it "should call failed_tagged_scenarios_for_application" do
            expect(instance).to receive(:failed_tagged_scenarios_for_application).with(application, :production)
            subject
          end

          it "should call worst_failure_type" do
            expect(new_scenario_collection).to receive(:worst_failure_type)
            subject
          end
        end

        context "with invalid failure type" do
          let(:failure){ 'something_else' }
          before do
            allow(new_scenario_collection).to receive(:worst_failure_type).and_return failure
          end

          it { is_expected.to eq 'operational' }

          it "should call failed_tagged_scenarios_for_application" do
            expect(instance).to receive(:failed_tagged_scenarios_for_application).with(application, :production)
            subject
          end

          it "should call worst_failure_type" do
            expect(new_scenario_collection).to receive(:worst_failure_type)
            subject
          end
        end
      end

      context "without application failures" do
        before { allow(new_scenario_collection).to receive(:worst_failure_type).and_return nil }

        it { is_expected.to eq "operational" }

        it "should call failed_tagged_scenarios_for_application" do
          expect(instance).to receive(:failed_tagged_scenarios_for_application).with(application, :production)
          subject
        end

        it "should not call worst_failure_type" do
          expect(new_scenario_collection).to receive(:worst_failure_type)
          subject
        end
      end
    end

    describe "failed_tagged_scenarios_for_application" do
      subject{ instance.failed_tagged_scenarios_for_application application, :production }

      context "with failing scenarios" do
        let(:application){ instance_double Browbeat::Application, symbol: "wxyz" }
        let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario4){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario5){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario6){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4, scenario5, scenario6] }
        # stub out has_tags? only for production
        before do
          allow(scenario1).to receive(:has_tags?).with(:production).and_return true
          allow(scenario2).to receive(:has_tags?).with(:production).and_return true
          allow(scenario3).to receive(:has_tags?).with(:production).and_return true
          allow(scenario4).to receive(:has_tags?).with(:production).and_return true
          allow(scenario5).to receive(:has_tags?).with(:production).and_return true
          allow(scenario6).to receive(:has_tags?).with(:production).and_return false
        end

        it { is_expected.to be_a Browbeat::ScenarioCollection }
        it { is_expected.to match_array [scenario2, scenario4] }
      end

      context "with failing production scenarios for other applications" do
        let(:application){ instance_double Browbeat::Application, symbol: "1234" }
        let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario4){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario5){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario6){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4, scenario5, scenario6] }
        # stub out has_tags? only for production
        before do
          allow(scenario1).to receive(:has_tags?).with(:production).and_return true
          allow(scenario2).to receive(:has_tags?).with(:production).and_return true
          allow(scenario3).to receive(:has_tags?).with(:production).and_return true
          allow(scenario4).to receive(:has_tags?).with(:production).and_return true
          allow(scenario5).to receive(:has_tags?).with(:production).and_return true
          allow(scenario6).to receive(:has_tags?).with(:production).and_return false
        end

        it { is_expected.to be_a Browbeat::ScenarioCollection }
        it { is_expected.to match_array [] }
      end

      context "with failing scenarios only on staging" do
        let(:application){ instance_double Browbeat::Application, symbol: "wxyz" }
        let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario4){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario5){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario6){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4, scenario5, scenario6] }
        # stub out has_tags? only for production
        before do
          allow(scenario1).to receive(:has_tags?).with(:production).and_return false
          allow(scenario2).to receive(:has_tags?).with(:production).and_return false
          allow(scenario3).to receive(:has_tags?).with(:production).and_return true
          allow(scenario4).to receive(:has_tags?).with(:production).and_return false
          allow(scenario5).to receive(:has_tags?).with(:production).and_return true
          allow(scenario6).to receive(:has_tags?).with(:production).and_return false
        end

        it { is_expected.to be_a Browbeat::ScenarioCollection }
        it { is_expected.to match_array [] }
      end

      context "with failing scenarios without failure type" do
        subject{ instance.failed_tagged_scenarios_for_application application }
        let(:application){ instance_double Browbeat::Application, symbol: "wxyz" }
        let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: nil, failure_type: nil }
        let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario4){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: nil, failure_type: nil }
        let(:scenario5){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: true, failure_severity: nil, failure_type: nil }
        let(:scenario6){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: nil, failure_type: nil }
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4, scenario5, scenario6] }
        # stub out has_tags? only for production
        before do
          allow(scenario1).to receive(:has_tags?).with(:production).and_return true
          allow(scenario2).to receive(:has_tags?).with(:production).and_return true
          allow(scenario3).to receive(:has_tags?).with(:production).and_return true
          allow(scenario4).to receive(:has_tags?).with(:production).and_return true
          allow(scenario5).to receive(:has_tags?).with(:production).and_return true
          allow(scenario6).to receive(:has_tags?).with(:production).and_return false
        end

        it { is_expected.to be_a Browbeat::ScenarioCollection }
        it { is_expected.to match_array [] }
      end
    end

    describe "tagged_scenarios_for_application?" do
      subject{ instance.tagged_scenarios_for_application? application, :staging }

      context "with successful scenarios matching the tag" do
        let(:application){ instance_double Browbeat::Application, symbol: "wxyz" }
        let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario4){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario5){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario6){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4, scenario5, scenario6] }
        # stub out has_tags? only for production
        before do
          allow(scenario1).to receive(:has_tags?).with(:staging).and_return true
          allow(scenario2).to receive(:has_tags?).with(:staging).and_return true
          allow(scenario3).to receive(:has_tags?).with(:staging).and_return true
          allow(scenario4).to receive(:has_tags?).with(:staging).and_return true
          allow(scenario5).to receive(:has_tags?).with(:staging).and_return true
          allow(scenario6).to receive(:has_tags?).with(:staging).and_return false
        end

        it { is_expected.to be_truthy }
      end

      context "with failing scenarios matching the tag" do
        let(:application){ instance_double Browbeat::Application, symbol: "wxyz" }
        let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario4){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario5){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario6){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4, scenario5, scenario6] }
        # stub out has_tags? only for production
        before do
          allow(scenario1).to receive(:has_tags?).with(:staging).and_return true
          allow(scenario2).to receive(:has_tags?).with(:staging).and_return true
          allow(scenario3).to receive(:has_tags?).with(:staging).and_return true
          allow(scenario4).to receive(:has_tags?).with(:staging).and_return true
          allow(scenario5).to receive(:has_tags?).with(:staging).and_return true
          allow(scenario6).to receive(:has_tags?).with(:staging).and_return false
        end

        it { is_expected.to be_truthy }
      end

      context "with failing scenarios for other applications matching the tag" do
        let(:application){ instance_double Browbeat::Application, symbol: "1234" }
        let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario4){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario5){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario6){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4, scenario5, scenario6] }
        # stub out has_tags? only for production
        before do
          allow(scenario1).to receive(:has_tags?).with(:staging).and_return true
          allow(scenario2).to receive(:has_tags?).with(:staging).and_return true
          allow(scenario3).to receive(:has_tags?).with(:staging).and_return true
          allow(scenario4).to receive(:has_tags?).with(:staging).and_return true
          allow(scenario5).to receive(:has_tags?).with(:staging).and_return true
          allow(scenario6).to receive(:has_tags?).with(:staging).and_return false
        end

        it { is_expected.to be_falsy }
      end

      context "with failing scenarios not matching the tag" do
        let(:application){ instance_double Browbeat::Application, symbol: "wxyz" }
        let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario4){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario5){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario6){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4, scenario5, scenario6] }
        # stub out has_tags? only for production
        before do
          allow(scenario1).to receive(:has_tags?).with(:staging).and_return false
          allow(scenario2).to receive(:has_tags?).with(:staging).and_return false
          allow(scenario3).to receive(:has_tags?).with(:staging).and_return true
          allow(scenario4).to receive(:has_tags?).with(:staging).and_return false
          allow(scenario5).to receive(:has_tags?).with(:staging).and_return true
          allow(scenario6).to receive(:has_tags?).with(:staging).and_return false
        end

        it { is_expected.to be_falsy }
      end

      context "without scenarios" do
        let(:application){ instance_double Browbeat::Application, symbol: "wxyz" }
        let(:scenario_collection){ Browbeat::ScenarioCollection.new([]) }

        it { is_expected.to be_falsy }
      end
    end

    describe "scenarios_for_application?" do
      subject{ instance.scenarios_for_application? application }

      context "with successful production scenarios" do
        let(:application){ instance_double Browbeat::Application, symbol: "wxyz" }
        let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario4){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario5){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario6){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4, scenario5, scenario6] }
        # stub out has_tags? only for production
        before do
          allow(scenario1).to receive(:has_tags?).with(:production).and_return true
          allow(scenario2).to receive(:has_tags?).with(:production).and_return true
          allow(scenario3).to receive(:has_tags?).with(:production).and_return true
          allow(scenario4).to receive(:has_tags?).with(:production).and_return true
          allow(scenario5).to receive(:has_tags?).with(:production).and_return true
          allow(scenario6).to receive(:has_tags?).with(:production).and_return false
        end

        it { is_expected.to be_truthy }
      end

      context "with failing production scenarios" do
        let(:application){ instance_double Browbeat::Application, symbol: "wxyz" }
        let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario4){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario5){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario6){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4, scenario5, scenario6] }
        # stub out has_tags? only for production
        before do
          allow(scenario1).to receive(:has_tags?).with(:production).and_return true
          allow(scenario2).to receive(:has_tags?).with(:production).and_return true
          allow(scenario3).to receive(:has_tags?).with(:production).and_return true
          allow(scenario4).to receive(:has_tags?).with(:production).and_return true
          allow(scenario5).to receive(:has_tags?).with(:production).and_return true
          allow(scenario6).to receive(:has_tags?).with(:production).and_return false
        end

        it { is_expected.to be_truthy }
      end

      context "with failing production scenarios for other applications" do
        let(:application){ instance_double Browbeat::Application, symbol: "1234" }
        let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario4){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario5){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario6){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4, scenario5, scenario6] }
        # stub out has_tags? only for production
        before do
          allow(scenario1).to receive(:has_tags?).with(:production).and_return true
          allow(scenario2).to receive(:has_tags?).with(:production).and_return true
          allow(scenario3).to receive(:has_tags?).with(:production).and_return true
          allow(scenario4).to receive(:has_tags?).with(:production).and_return true
          allow(scenario5).to receive(:has_tags?).with(:production).and_return true
          allow(scenario6).to receive(:has_tags?).with(:production).and_return false
        end

        it { is_expected.to be_falsy }
      end

      context "with failing scenarios only on staging" do
        let(:application){ instance_double Browbeat::Application, symbol: "wxyz" }
        let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario4){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario5){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario6){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: 0, failure_type: 'major_outage' }
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4, scenario5, scenario6] }
        # stub out has_tags? only for production
        before do
          allow(scenario1).to receive(:has_tags?).with(:production).and_return false
          allow(scenario2).to receive(:has_tags?).with(:production).and_return false
          allow(scenario3).to receive(:has_tags?).with(:production).and_return true
          allow(scenario4).to receive(:has_tags?).with(:production).and_return false
          allow(scenario5).to receive(:has_tags?).with(:production).and_return true
          allow(scenario6).to receive(:has_tags?).with(:production).and_return false
        end

        it { is_expected.to be_truthy }
      end

      context "with failing scenarios with no failure type" do
        let(:application){ instance_double Browbeat::Application, symbol: "wxyz" }
        let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: nil, failure_type: nil }
        let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: false, failure_severity: nil, failure_type: nil }
        let(:scenario4){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: nil, failure_type: nil }
        let(:scenario5){ instance_double Browbeat::Scenario, app_symbol: "abcd", failed?: true, failure_severity: nil, failure_type: nil }
        let(:scenario6){ instance_double Browbeat::Scenario, app_symbol: "wxyz", failed?: true, failure_severity: nil, failure_type: nil }
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4, scenario5, scenario6] }
        # stub out has_tags? only for production
        before do
          allow(scenario1).to receive(:has_tags?).with(:production).and_return true
          allow(scenario2).to receive(:has_tags?).with(:production).and_return true
          allow(scenario3).to receive(:has_tags?).with(:production).and_return true
          allow(scenario4).to receive(:has_tags?).with(:production).and_return true
          allow(scenario5).to receive(:has_tags?).with(:production).and_return true
          allow(scenario6).to receive(:has_tags?).with(:production).and_return false
        end

        it { is_expected.to be_truthy }
      end

      context "without scenarios" do
        let(:application){ instance_double Browbeat::Application, symbol: "wxyz" }
        let(:scenario_collection){ Browbeat::ScenarioCollection.new([]) }

        it { is_expected.to be_falsy }
      end
    end
  end
end

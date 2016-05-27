require 'spec_helper'
require 'failure_tracker'

describe FailureTracker::Formatters::MailFailureFormatter do
  describe "class methods" do
    describe "self.render" do
      subject { described_class.render scenario_collection }
      let(:formatter){ double described_class }
      let(:scenario_collection){ double FailureTracker::ScenarioCollection }
      let(:result){ "<div>Hello!</div>" }
      before do
        allow(described_class).to receive(:new).and_return formatter
        allow(formatter).to receive(:render).and_return result
      end

      it { is_expected.to eq result }

      it "should instantiate instance correctly" do
        expect(described_class).to receive(:new).with scenario_collection
        subject
      end

      it "should call render on that instance" do
        expect(formatter).to receive(:render)
        subject
      end
    end
  end

  describe "instance methods" do
    let(:scenario_collection){ double FailureTracker::ScenarioCollection }
    let(:formatter){ described_class.new scenario_collection }

    describe "render" do
      subject { formatter.render }
      let(:file_text){ "%div =environments" }
      let(:engine){ double Haml::Engine }
      let(:result){ "Hello world!" }
      before do
        allow(File).to receive(:read).and_return file_text
        allow(Haml::Engine).to receive(:new).and_return engine
        allow(engine).to receive(:render).and_return result
      end

      it { is_expected.to eq result }

      it "should call File.read correctly" do
        expect(File).to receive(:read).with("lib/failure_tracker/templates/mail_failure.html.haml")
        subject
      end

      it "should instantiate engine correctly" do
        expect(Haml::Engine).to receive(:new).with(file_text)
        subject
      end

      it "should call render correctly" do
        expect(engine).to receive(:render).with(formatter)
        subject
      end
    end

    describe "application_list" do
      subject { formatter.application_list }
      let(:list){ double Array }
      it "should call Application.list and return result" do
        expect(FailureTracker::Application).to receive(:list_all).and_return list
        expect(subject).to eq list
      end
    end

    describe "environments" do
      subject { formatter.environments }
      it { is_expected.to eq %w[production staging] }
    end

    describe "failure_types" do
      subject { formatter.failure_types }
      it { is_expected.to eq %w[major_outage partial_outage degraded_performance] }
    end

    describe "scenarios_for_application?" do
      subject { formatter.scenarios_for_application? application }

      context "with scenarios" do
        let(:scenario_collection){ FailureTracker::ScenarioCollection.new [scenario1, scenario2] }
        let(:scenario1){ double FailureTracker::Scenario, app_symbol: 'abcd' }
        let(:scenario2){ double FailureTracker::Scenario, app_symbol: 'wxyz' }

        context "with corresponding application" do
          let(:application){ double FailureTracker::Application, symbol: 'wxyz' }
          it { is_expected.to be_truthy }
        end

        context "with non-corresponding application" do
          let(:application){ double FailureTracker::Application, symbol: '1234' }
          it { is_expected.to be_falsy }
        end
      end
    end

    describe "scenarios_for_application" do
      subject { formatter.scenarios_for_application application }

      context "with scenarios" do
        let(:scenario_collection){ FailureTracker::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4] }
        let(:scenario1){ double FailureTracker::Scenario, app_symbol: 'abcd' }
        let(:scenario2){ double FailureTracker::Scenario, app_symbol: 'wxyz' }
        let(:scenario3){ double FailureTracker::Scenario, app_symbol: 'wxyz' }
        let(:scenario4){ double FailureTracker::Scenario, app_symbol: '4567' }

        context "with corresponding application" do
          let(:application){ double FailureTracker::Application, symbol: '4567' }
          it { is_expected.to match_array [scenario4] }
          it { is_expected.to be_a FailureTracker::ScenarioCollection }
        end

        context "with corresponding application matching multiple" do
          let(:application){ double FailureTracker::Application, symbol: 'wxyz' }
          it { is_expected.to match_array [scenario2, scenario3] }
          it { is_expected.to be_a FailureTracker::ScenarioCollection }
        end

        context "with non-corresponding application" do
          let(:application){ double FailureTracker::Application, symbol: '1234' }
          it { is_expected.to match_array [] }
          it { is_expected.to be_a FailureTracker::ScenarioCollection }
        end
      end

    end

    describe "scenarios_for_application_environment?" do
      subject { formatter.scenarios_for_application_environment? application, environment }
      let(:application){ double FailureTracker::Application }
      let(:environment){ "something" }

      context "with application scenarios" do
        let(:subcollection){ FailureTracker::ScenarioCollection.new [scenario1, scenario2, scenario3] }
        before { allow(formatter).to receive(:scenarios_for_application).and_return subcollection }

        context "with environment tag" do
          let(:scenario1){ double FailureTracker::Scenario, has_tag?: false }
          let(:scenario2){ double FailureTracker::Scenario, has_tag?: true }
          let(:scenario3){ double FailureTracker::Scenario, has_tag?: false }

          it { is_expected.to be_truthy }

          it "should call has_tag? via any?" do
            expect(formatter).to receive(:scenarios_for_application).with(application)
            expect(scenario1).to receive(:has_tag?).with environment
            expect(scenario2).to receive(:has_tag?).with environment
            expect(scenario3).to_not receive(:has_tag?)
            subject
          end
        end

        context "without environment tag" do
          let(:scenario1){ double FailureTracker::Scenario, has_tag?: false }
          let(:scenario2){ double FailureTracker::Scenario, has_tag?: false }
          let(:scenario3){ double FailureTracker::Scenario, has_tag?: false }

          it { is_expected.to be_falsy }

          it "should call has_tag? via any?" do
            expect(formatter).to receive(:scenarios_for_application).with(application)
            expect(scenario1).to receive(:has_tag?).with environment
            expect(scenario2).to receive(:has_tag?).with environment
            expect(scenario3).to receive(:has_tag?).with environment
            subject
          end
        end
      end

      context "without application scenarios" do
        let(:subcollection){ FailureTracker::ScenarioCollection.new [] }
        before { allow(formatter).to receive(:scenarios_for_application).and_return subcollection }

        it { is_expected.to be_falsy }
      end
    end # end scenarios_for_application_environment?

    describe "scenarios_for_application_environment_failure_type" do
      subject { formatter.scenarios_for_application_environment_failure_type application, environment, failure_type }
      let(:application){ double FailureTracker::Application }
      let(:environment){ "something" }
      let(:failure_type){ "catastrophic" }
      let(:subcollection){ double FailureTracker::ScenarioCollection }
      let(:subsubcollection){ double FailureTracker::ScenarioCollection }
      before do
        allow(formatter).to receive(:scenarios_for_application).and_return subcollection
        allow(subcollection).to receive(:with_tags).and_return subsubcollection
      end

      it { is_expected.to eq subsubcollection }

      it "should call scenarios_for_application correctly" do
        expect(formatter).to receive(:scenarios_for_application).with(application)
        expect(subcollection).to receive(:with_tags).with(environment, failure_type)
        subject
      end
    end # end scenarios_for_application_environment_failure_type
  end
end
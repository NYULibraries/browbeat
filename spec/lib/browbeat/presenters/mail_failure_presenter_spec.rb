require 'spec_helper'
require 'browbeat'

describe Browbeat::Presenters::MailFailurePresenter do
  describe "class methods" do
    describe "self.render" do
      subject { described_class.render scenario_collection, applications, environments }
      let(:presenter){ instance_double described_class }
      let(:scenario_collection){ instance_double Browbeat::ScenarioCollection }
      let(:applications){ [instance_double(Browbeat::Application), instance_double(Browbeat::Application)] }
      let(:environments){ %w[production staging] }
      let(:result){ "<div>Hello!</div>" }
      before do
        allow(described_class).to receive(:new).and_return presenter
        allow(presenter).to receive(:render).and_return result
      end

      it { is_expected.to eq result }

      it "should instantiate instance correctly" do
        expect(described_class).to receive(:new).with scenario_collection, applications, environments
        subject
      end

      it "should call render on that instance" do
        expect(presenter).to receive(:render)
        subject
      end
    end
  end

  describe "instance methods" do
    let(:scenario_collection){ instance_double Browbeat::ScenarioCollection }
    let(:applications){ [instance_double(Browbeat::Application), instance_double(Browbeat::Application)] }
    let(:environments){ %w[some_env another_env] }
    let(:presenter){ described_class.new scenario_collection, applications, environments }

    describe "render" do
      subject { presenter.render }
      let(:file_text){ "%div =environments" }
      let(:engine){ instance_double Haml::Engine }
      let(:result){ "Hello world!" }
      before do
        allow(File).to receive(:read).and_return file_text
        allow(Haml::Engine).to receive(:new).and_return engine
        allow(engine).to receive(:render).and_return result
      end

      it { is_expected.to eq result }

      it "should call File.read correctly" do
        expect(File).to receive(:read).with("lib/browbeat/templates/mail_failure.html.haml")
        subject
      end

      it "should instantiate engine correctly" do
        expect(Haml::Engine).to receive(:new).with(file_text)
        subject
      end

      it "should call render correctly" do
        expect(engine).to receive(:render).with(presenter)
        subject
      end
    end

    describe "application_list" do
      subject { presenter.application_list }
      it { is_expected.to eq applications }
    end

    describe "environments" do
      subject { presenter.environments }
      it { is_expected.to eq environments }
    end

    describe "failure_types" do
      subject { presenter.failure_types }
      it { is_expected.to eq %w[major_outage partial_outage degraded_performance warning] }
    end

    describe "ordered_application_list" do
      subject { presenter.ordered_application_list }
      let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4, scenario5] }
      let(:applications){ Browbeat::ApplicationCollection.new [application1, application2, application3] }
      let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: "abc", failure_severity: 2 }
      let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: "def", failure_severity: 2 }
      let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: "abc", failure_severity: 3 }
      let(:scenario4){ instance_double Browbeat::Scenario, app_symbol: "ghi", failure_severity: 1 }
      let(:scenario5){ instance_double Browbeat::Scenario, app_symbol: "def", failure_severity: 0 }
      let(:application1){ instance_double Browbeat::Application, symbol: "abc" }
      let(:application2){ instance_double Browbeat::Application, symbol: "def" }
      let(:application3){ instance_double Browbeat::Application, symbol: "ghi" }

      it { is_expected.to be_a Browbeat::ApplicationCollection }
      it "should be ordered correctly" do
        expect(subject.to_a).to eq [application2, application3, application1]
      end
    end

    describe "scenarios_for_application?" do
      subject { presenter.scenarios_for_application? application }

      context "with scenarios" do
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2] }
        let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: 'abcd' }
        let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: 'wxyz' }

        context "with corresponding application" do
          let(:application){ instance_double Browbeat::Application, symbol: 'wxyz' }
          it { is_expected.to be_truthy }
        end

        context "with non-corresponding application" do
          let(:application){ instance_double Browbeat::Application, symbol: '1234' }
          it { is_expected.to be_falsy }
        end
      end
    end

    describe "scenarios_for_application" do
      subject { presenter.scenarios_for_application application }

      context "with scenarios" do
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4] }
        let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: 'abcd' }
        let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: 'wxyz' }
        let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: 'wxyz' }
        let(:scenario4){ instance_double Browbeat::Scenario, app_symbol: '4567' }

        context "with corresponding application" do
          let(:application){ instance_double Browbeat::Application, symbol: '4567' }
          it { is_expected.to match_array [scenario4] }
          it { is_expected.to be_a Browbeat::ScenarioCollection }
        end

        context "with corresponding application matching multiple" do
          let(:application){ instance_double Browbeat::Application, symbol: 'wxyz' }
          it { is_expected.to match_array [scenario2, scenario3] }
          it { is_expected.to be_a Browbeat::ScenarioCollection }
        end

        context "with non-corresponding application" do
          let(:application){ instance_double Browbeat::Application, symbol: '1234' }
          it { is_expected.to match_array [] }
          it { is_expected.to be_a Browbeat::ScenarioCollection }
        end
      end

    end

    describe "worst_application_failure" do
      subject{ presenter.worst_application_failure(application) }
      let(:application){ instance_double Browbeat::Application }
      let(:scenario_collection){ instance_double Browbeat::ScenarioCollection, worst_failure_type: worst_failure_type }
      before { allow(presenter).to receive(:scenarios_for_application).and_return scenario_collection }

      context "with worst_failure_type" do
        let(:worst_failure_type){ 'major_outage' }

        it { is_expected.to eq "major outage" }
        it "should call scenarios_for_application properly" do
          expect(presenter).to receive(:scenarios_for_application).with(application)
          subject
        end
      end

      context "without worst_failure_type" do
        let(:worst_failure_type){ nil }

        it { is_expected.to eq nil }
        it "should call scenarios_for_application properly" do
          expect(presenter).to receive(:scenarios_for_application).with(application)
          subject
        end
      end
    end

    describe "scenarios_for_application_failure_type" do
      subject{ presenter.scenarios_for_application_failure_type(application, failure_type) }
      let(:application){ instance_double Browbeat::Application }
      let(:scenario_collection){ instance_double Browbeat::ScenarioCollection, with_tags: subcollection }
      let(:subcollection){ instance_double Browbeat::ScenarioCollection }
      let(:failure_type){ "catastrophic" }
      before { allow(presenter).to receive(:scenarios_for_application).and_return scenario_collection }

      it { is_expected.to eq subcollection }

      it "should call scenarios_for_application correctly" do
        expect(presenter).to receive(:scenarios_for_application).with(application)
        expect(scenario_collection).to receive(:with_tags).with(failure_type)
        subject
      end
    end

    describe "standardize_line" do
      subject{ presenter.standardize_line(line) }

      context "with valid line" do
        let(:line){ "./features/step_definitions/shared_step_definitions.rb:49:in `/^I search for \"(.*?)\"$/'" }

        it { is_expected.to eq "features/step_definitions/shared_step_definitions.rb:49:in `/^I search for \"(.*?)\"$/'" }
      end

      context "with invalid line" do
        let(:line){ "/some/unknown/path:49" }

        it "should raise error" do
          expect{ subject }.to raise_error "Could not match line: '#{line}'"
        end
      end
    end

    describe "file_link" do
      subject{ presenter.file_link(line) }

      context "with valid line" do
        let(:line){ "./features/step_definitions/shared_step_definitions.rb:49:in `/^I search for \"(.*?)\"$/'" }

        it { is_expected.to eq "https://github.com/NYULibraries/browbeat/blob/master/features/step_definitions/shared_step_definitions.rb#L49" }
      end

      context "with invalid line" do
        let(:line){ "/some/unknown/path:49" }

        it "should raise error" do
          expect{ subject }.to raise_error "Could not match line: '#{line}'"
        end
      end
    end

    describe "github_screenshot_link" do
      subject{ presenter.github_screenshot_link(scenario, extension: extension) }
      let(:scenario){ instance_double Browbeat::Scenario }
      let(:extension){ 'png' }
      before { allow(presenter).to receive(:build_tag).and_return build_tag }

      context "with build_tag" do
        let(:build_tag){ "abcdef" }
        before { allow(scenario).to receive(:screenshot_filename).and_return local_path }

        context "with valid local path" do
          let(:local_path){ "something_else.png" }

          it { is_expected.to eq "https://github.com/NYULibraries/browbeat-screenshots/blob/abcdef/something_else.png" }

          it "should call screenshot_filename correctly" do
            expect(scenario).to receive(:screenshot_filename).with(extension: 'png')
            subject
          end
        end

        context "without local path" do
          let(:local_path){ nil }

          it { is_expected.to eq nil }
        end
      end

      context "without build_tag" do
        let(:build_tag){ nil }

        it { is_expected.to eq nil }
      end
    end

    describe "build_tag" do
      subject{ presenter.build_tag }
      around do |example|
        with_modified_env BUILD_TAG: build_tag do
          example.run
        end
      end

      context "with build_tag not set" do
        let(:build_tag){ nil }

        it { is_expected.to eq nil }
      end

      context "with build_tag set" do
        let(:build_tag){ "jenkins-Browbeat Production Check All-123" }

        it { is_expected.to eq "jenkins-Browbeat_Production_Check_All-123" }
      end
    end
  end
end

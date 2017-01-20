require 'spec_helper'
require 'browbeat'

describe Browbeat::StepEvent do
  let(:step_event){ described_class.new(cucumber_event) }
  let(:cucumber_event){ instance_double Cucumber::Events::AfterTestStep, test_step: test_step }
  let(:test_step){ instance_double Cucumber::Core::Test::Step, source: [cucumber_step] }
  let(:cucumber_step){ instance_double Cucumber::Core::Ast::Step, is_a?: true }

  describe "scenario_step?" do
    subject{ step_event.scenario_step? }
    let(:cucumber_event){ instance_double Cucumber::Events::AfterTestStep, test_step: test_step }
    let(:test_step){ instance_double Cucumber::Core::Test::Step, source: [cucumber_step], location: location }
    let(:location){ instance_double Cucumber::Core::Ast::Location::Precise, file: file }

    context "with file in features/" do
      context "and not in callbacks.rb" do
        let(:file){ "features/primo/appearance.feature" }

        it { is_expected.to be_truthy }
      end

      context "and in callbacks.rb" do
        let(:file){ "features/support/callbacks.rb" }

        it { is_expected.to be_falsy }
      end
    end

    context "with file not in features/" do
      let(:file){ "/Users/Eric/.rbenv/versions/2.3.3/lib/ruby/gems/2.3.0/gems/capybara-2.7.1/lib/capybara/session.rb:233:in `visit'" }

      it { is_expected.to be_falsy }
    end
  end

  # describe "step_definition_location" do
  #   subject{ step_event.step_definition_location }
  #
  #
  # end

  describe "name" do
    subject{ step_event.name }
    let(:cucumber_step){ instance_double Cucumber::Core::Ast::Step, is_a?: true, actual_keyword: actual_keyword, name: step_name }
    let(:actual_keyword){ "Given " }
    let(:step_name){ "I visit BobCat" }

    it { is_expected.to eq "Given I visit BobCat" }
  end

  describe "status" do
    subject{ step_event.status }
    let(:cucumber_event){ instance_double Cucumber::Events::AfterTestStep, test_step: test_step, result: result }

    context "with failing result" do
      let(:result){ instance_double Cucumber::Core::Test::Result::Failed, failed?: true }

      it { is_expected.to eq :failed }
    end

    context "with passing result" do
      let(:result){ instance_double Cucumber::Core::Test::Result::Passed, failed?: false, passed?: true }

      it { is_expected.to eq :passed }
    end

    context "with pending result" do
      let(:result){ instance_double Cucumber::Core::Test::Result::Passed, failed?: false, passed?: false, pending?: true }

      it { is_expected.to eq :pending }
    end

    context "with skipped result" do
      let(:result){ instance_double Cucumber::Core::Test::Result::Passed, failed?: false, passed?: false, pending?: false, skipped?: true }

      it { is_expected.to eq :skipped }
    end
  end
end

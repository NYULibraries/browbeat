require 'spec_helper'
require 'browbeat'

describe Browbeat::Scenario do
  describe "scenario methods" do
    let(:cucumber_scenario){ instance_double Cucumber::Core::Test::Case }
    let(:scenario){ described_class.new(cucumber_scenario) }

    describe "cucumber_scenario" do
      subject{ scenario.cucumber_scenario }
      it{ is_expected.to eq cucumber_scenario }
    end

    describe "tag_names" do
      subject{ scenario.tag_names }
      let(:cucumber_scenario){ instance_double Cucumber::Core::Test::Case, tags: tags }

      describe "with tags" do
        let(:tags){ [tag1, tag2, tag3] }
        let(:tag1){ instance_double Cucumber::Core::Ast::Tag, name: "@some_tag" }
        let(:tag2){ instance_double Cucumber::Core::Ast::Tag, name: "@other_tag" }
        let(:tag3){ instance_double Cucumber::Core::Ast::Tag, name: "@last_tag" }

        it { is_expected.to match_array %w[@some_tag @other_tag @last_tag] }
      end

      describe "without tags" do
        let(:tags){ [] }

        it { is_expected.to eq [] }
      end
    end

    describe "backtrace_line" do
      subject{ scenario.backtrace_line }
      describe "with an exception" do
        let(:cucumber_scenario){ instance_double Cucumber::RunningTestCase::Scenario, exception: exception }
        let(:exception){ instance_double RuntimeError, backtrace: backtrace }
        let(:backtrace) do
          ["/Users/Eric/.rbenv/versions/2.3.3/lib/ruby/gems/2.3.0/gems/poltergeist-1.10.0/lib/capybara/poltergeist/browser.rb:365:in `command'",
           "/Users/Eric/.rbenv/versions/2.3.3/lib/ruby/gems/2.3.0/gems/poltergeist-1.10.0/lib/capybara/poltergeist/browser.rb:35:in `visit'",
           "/Users/Eric/.rbenv/versions/2.3.3/lib/ruby/gems/2.3.0/gems/poltergeist-1.10.0/lib/capybara/poltergeist/driver.rb:97:in `visit'",
           "/Users/Eric/.rbenv/versions/2.3.3/lib/ruby/gems/2.3.0/gems/capybara-2.7.1/lib/capybara/session.rb:233:in `visit'",
           "/Users/Eric/.rbenv/versions/2.3.3/lib/ruby/gems/2.3.0/gems/capybara-2.7.1/lib/capybara/dsl.rb:52:in `block (2 levels) in <module:DSL>'",
           "./features/step_definitions/shared_step_definitions.rb:2:in `/^I visit (.+)$/'",
           "features/eshelf/ping.feature:9:in `Given I visit e-Shelf'"]
        end

        it { is_expected.to eq "features/eshelf/ping.feature:9:in `Given I visit e-Shelf'" }
      end

      describe "without an exception" do
        let(:cucumber_scenario){ instance_double Cucumber::RunningTestCase::Scenario, exception: nil }

        it { is_expected.to eq nil }
      end
    end

    describe "file" do
      subject{ scenario.file }
      let(:cucumber_scenario){ instance_double Cucumber::Core::Test::Case, inspect: "#<Cucumber::Core::Test::Case: features/eshelf/ping.feature:8>" }

      it { is_expected.to eq "features/eshelf/ping.feature" }
    end

    describe "failure_type" do
      subject{ scenario.failure_type }
      before do
        allow(scenario).to receive(:tag_names).and_return tag_names
      end

      context "with failure" do
        before do
          allow(scenario).to receive(:failed?).and_return true
        end

        context "with major_outage tag" do
          let(:tag_names){ ["@production", "@major_outage", "@ping", "@selenium"] }
          it{ is_expected.to eq 'major_outage' }
        end

        context "with partial_outage tag" do
          let(:tag_names){ ["@staging", "@functionality", "@selenium", "@partial_outage"] }
          it{ is_expected.to eq 'partial_outage' }
        end

        context "with degraded_performance tag" do
          let(:tag_names){ ["@degraded_performance", "@staging", "@functionality", "@selenium"] }
          it{ is_expected.to eq 'degraded_performance' }
        end
      end

      context "without failure" do
        before do
          allow(scenario).to receive(:failed?).and_return false
        end

        context "with major_outage tag" do
          let(:tag_names){ ["@production", "@major_outage", "@ping", "@selenium"] }
          it{ is_expected.to eq nil }
        end

        context "with partial_outage tag" do
          let(:tag_names){ ["@staging", "@functionality", "@selenium", "@partial_outage"] }
          it{ is_expected.to eq nil }
        end

        context "with degraded_performance tag" do
          let(:tag_names){ ["@degraded_performance", "@staging", "@functionality", "@selenium"] }
          it{ is_expected.to eq nil }
        end
      end

    end

    describe "failure_severity" do
      subject{ scenario.failure_severity }
      before do
        allow(scenario).to receive(:failure_type).and_return failure_type
      end

      context "with major_outage" do
        let(:failure_type){ 'major_outage' }
        it{ is_expected.to eq 0 }
      end

      context "with major_outage" do
        let(:failure_type){ 'partial_outage' }
        it{ is_expected.to eq 1 }
      end

      context "with degraded_performance" do
        let(:failure_type){ 'degraded_performance' }
        it{ is_expected.to eq 2 }
      end
    end

    describe "app_symbol" do
      subject{ scenario.app_symbol }
      before do
        allow(scenario).to receive(:file).and_return file
      end

      context "with relative filepath" do
        let(:file){ "features/super-great_app/example.feature" }
        it{ is_expected.to eq 'super-great_app' }
      end
    end

    # describe "failed_step" do
    #   subject{ scenario.failed_step }
    #   let(:step1){ instance_double Cucumber::Ast::StepInvocation }
    #   let(:step2){ instance_double Cucumber::Ast::StepInvocation }
    #   let(:step3){ instance_double Cucumber::Ast::StepInvocation }
    #   before do
    #     allow(scenario).to receive(:steps).and_return [step1, step2, step3]
    #   end
    #
    #   context "second step failing" do
    #     before do
    #       allow(step1).to receive(:status).and_return :passed
    #       allow(step2).to receive(:status).and_return :failed
    #       allow(step3).to receive(:status).and_return :skipped
    #     end
    #
    #     it{ is_expected.to eq step2 }
    #   end
    #
    #   context "no steps failing" do
    #     before do
    #       allow(step1).to receive(:status).and_return :passed
    #       allow(step2).to receive(:status).and_return :passed
    #       allow(step3).to receive(:status).and_return :skipped
    #     end
    #
    #     it{ is_expected.to eq nil }
    #   end
    # end

    describe "has_tags?" do
      let(:tag_names){ ["@production", "@major_outage", "@ping", "@selenium"] }
      before do
        allow(scenario).to receive(:tag_names).and_return tag_names
      end

      it "should return true if all tags given match case-insensitively" do
        expect(scenario.has_tags? :production, "@pinG", "Selenium").to eq true
      end

      it "should return false if one tag doesn't match" do
        expect(scenario.has_tags? "@Production", :ping, "another").to eq false
      end

      it "should return false if one tag is blank" do
        expect(scenario.has_tags? :production, "@pinG", nil).to eq false
      end
    end

    describe "has_tag?" do
      let(:tag_names){ ["@production", "@major_outage", "@ping", "@selenium"] }
      before do
        allow(scenario).to receive(:tag_names).and_return tag_names
      end

      it "should return true if any tag matches case-insensitively with '@'" do
        expect(scenario.has_tag? '@pIng').to eq true
      end

      it "should return true if any tag matches case-insensitively without '@'" do
        expect(scenario.has_tag? 'Production').to eq true
      end

      it "should return true if any tags matches case-insensitively even if a symbol" do
        expect(scenario.has_tag? :major_outage).to eq true
      end

      it "should return false if a tag only partially matches" do
        expect(scenario.has_tag? '@pin').to eq false
        expect(scenario.has_tag? 'roduction').to eq false
      end

      it "should return false for a blank tag" do
        expect(scenario.has_tag? '').to eq false
        expect(scenario.has_tag? nil).to eq false
      end
    end
  end
end

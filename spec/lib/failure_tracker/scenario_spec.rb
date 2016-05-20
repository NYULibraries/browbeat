require 'spec_helper'
require 'failure_tracker'

describe FailureTracker::Scenario do
  describe "scenario methods" do
    let(:cucumber_scenario){ double Cucumber::Ast::Scenario }
    let(:scenario){ described_class.new cucumber_scenario }

    describe "cucumber_scenario" do
      subject{ scenario.cucumber_scenario }
      it{ is_expected.to eq cucumber_scenario }
    end

    describe "failure_type" do
      subject{ scenario.failure_type }
      before do
        allow(scenario).to receive(:source_tag_names).and_return tags
      end

      context "with failure" do
        before do
          allow(scenario).to receive(:failed?).and_return true
        end

        context "with major_outage tag" do
          let(:tags){ ["@production", "@major_outage", "@ping", "@selenium"] }
          it{ is_expected.to eq 'major_outage' }
        end

        context "with partial_outage tag" do
          let(:tags){ ["@staging", "@functionality", "@selenium", "@partial_outage"] }
          it{ is_expected.to eq 'partial_outage' }
        end

        context "with degraded_performance tag" do
          let(:tags){ ["@degraded_performance", "@staging", "@functionality", "@selenium"] }
          it{ is_expected.to eq 'degraded_performance' }
        end
      end

      context "without failure" do
        before do
          allow(scenario).to receive(:failed?).and_return false
        end

        context "with major_outage tag" do
          let(:tags){ ["@production", "@major_outage", "@ping", "@selenium"] }
          it{ is_expected.to eq nil }
        end

        context "with partial_outage tag" do
          let(:tags){ ["@staging", "@functionality", "@selenium", "@partial_outage"] }
          it{ is_expected.to eq nil }
        end

        context "with degraded_performance tag" do
          let(:tags){ ["@degraded_performance", "@staging", "@functionality", "@selenium"] }
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

    describe "failed_step" do
      subject{ scenario.failed_step }
      let(:step1){ double Cucumber::Ast::StepInvocation }
      let(:step2){ double Cucumber::Ast::StepInvocation }
      let(:step3){ double Cucumber::Ast::StepInvocation }
      before do
        allow(scenario).to receive(:steps).and_return [step1, step2, step3]
      end

      context "second step failing" do
        before do
          allow(step1).to receive(:status).and_return :passed
          allow(step2).to receive(:status).and_return :failed
          allow(step3).to receive(:status).and_return :skipped
        end

        it{ is_expected.to eq step2 }
      end

      context "no steps failing" do
        before do
          allow(step1).to receive(:status).and_return :passed
          allow(step2).to receive(:status).and_return :passed
          allow(step3).to receive(:status).and_return :skipped
        end

        it{ is_expected.to eq nil }
      end
    end

    describe "has_tags?" do
      let(:tags){ ["@production", "@major_outage", "@ping", "@selenium"] }
      before do
        allow(scenario).to receive(:source_tag_names).and_return tags
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
      let(:tags){ ["@production", "@major_outage", "@ping", "@selenium"] }
      before do
        allow(scenario).to receive(:source_tag_names).and_return tags
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

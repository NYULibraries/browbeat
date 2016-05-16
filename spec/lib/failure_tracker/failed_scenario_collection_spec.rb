require 'spec_helper'
require 'failure_tracker'

describe FailureTracker::FailedScenarioCollection do
  let(:klass){ FailureTracker::FailedScenarioCollection }

  describe "instance methods" do
    let(:scenario1){ double FailureTracker::FailedScenario }
    let(:scenario2){ double FailureTracker::FailedScenario }
    let(:scenario3){ double FailureTracker::FailedScenario }
    let(:collection){ klass.new scenarios }

    describe "with_tags" do
      before do
        allow(scenario1).to receive(:has_tags?)
        allow(scenario2).to receive(:has_tags?)
        allow(scenario3).to receive(:has_tags?)
      end

      context "with scenarios" do
        let(:scenarios){ [scenario1, scenario2, scenario3] }
        subject{ collection.with_tags(:test, :ping) }

        it{ is_expected.to be_a klass }

        it{ is_expected.to_not eq collection }

        it "should return an collection whose scenarios return true for has_tags?" do
          expect(scenario1).to receive(:has_tags?).with(:test, :ping).and_return false
          expect(scenario2).to receive(:has_tags?).with(:test, :ping).and_return true
          expect(scenario3).to receive(:has_tags?).with(:test, :ping).and_return true
          expect(subject.to_a).to match_array [scenario2, scenario3]
        end
      end

      context "without scenarios" do
        let(:scenarios){ [] }
        subject{ collection.with_tags(:test, :ping) }

        it{ is_expected.to be_a klass }

        it{ is_expected.to_not eq collection }

        it{ is_expected.to be_empty }
      end
    end

    describe "select" do
      context "using app_name" do
        subject{ collection.select{|s| s.app_name == 'app2' } }
        before do
          allow(scenario1).to receive(:app_name).and_return 'app1'
          allow(scenario2).to receive(:app_name).and_return 'app2'
          allow(scenario3).to receive(:app_name).and_return 'app2'
        end

        context "with scenarios" do
          let(:scenarios){ [scenario1, scenario2, scenario3] }

          it { is_expected.to be_a klass }
          it "should have correct constituents" do
            expect(subject.to_a).to match_array [scenario2, scenario3]
          end
        end
      end
    end

    describe "group_by" do
      context "using app_name" do
        subject{ collection.group_by(&:app_name) }
        before do
          allow(scenario1).to receive(:app_name).and_return 'app1'
          allow(scenario2).to receive(:app_name).and_return 'app2'
          allow(scenario3).to receive(:app_name).and_return 'app1'
        end

        context "with scenarios" do
          let(:scenarios){ [scenario1, scenario2, scenario3] }

          it{ is_expected.to be_a Hash }
          it "should group by app1" do
            expect(subject["app1"]).to be_a klass
            expect(subject["app1"]).to include scenario1
            expect(subject["app1"]).to include scenario3
          end
          it "should group by app2" do
            expect(subject["app2"]).to be_a klass
            expect(subject["app2"]).to include scenario2
          end
        end

        context "without scenarios" do
          let(:scenarios){ [] }

          it{ is_expected.to be_a Hash }
          it{ is_expected.to be_empty }
        end
      end
    end

    describe "worst_failure_type" do
      subject{ collection.worst_failure_type }

      context "with scenarios" do
        let(:scenarios){ [scenario1, scenario2, scenario3] }

        context "with non-nil failure severity" do
          before do
            allow(scenario1).to receive(:failure_type).and_return 'abc'
            allow(scenario2).to receive(:failure_type).and_return 'efg'
            allow(scenario3).to receive(:failure_type).and_return 'hij'
            allow(scenario1).to receive(:failure_severity).and_return 1
            allow(scenario2).to receive(:failure_severity).and_return 0
            allow(scenario3).to receive(:failure_severity).and_return 2
          end

          it{ is_expected.to eq 'efg' }
        end

        context "with nil failure severity" do
          before do
            allow(scenario1).to receive(:failure_type).and_return 'abc'
            allow(scenario2).to receive(:failure_type).and_return 'efg'
            allow(scenario3).to receive(:failure_type).and_return 'hij'
            allow(scenario1).to receive(:failure_severity).and_return nil
            allow(scenario2).to receive(:failure_severity).and_return 1
            allow(scenario3).to receive(:failure_severity).and_return 0
          end

          it{ is_expected.to eq 'hij' }
        end
      end

      context "without scenarios" do
        let(:scenarios){ [] }

        it{ is_expected.to eq nil }
      end
    end
  end
end

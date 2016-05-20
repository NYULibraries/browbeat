require 'spec_helper'
require 'failure_tracker'

describe FailureTracker::StatusMailer do
  describe "class methods" do
    describe "self.send_status" do
      subject { described_class.send_status scenario_collection }
      let(:mailer){ double described_class }
      let(:scenario_collection){ double FailureTracker::ScenarioCollection }
      before do
        allow(described_class).to receive(:new).and_return mailer
        allow(mailer).to receive(:send_status_if_failed).and_return true
      end

      it "should instantiate instance correctly" do
        expect(described_class).to receive(:new).with scenario_collection
        subject
      end

      it "should call send_status_if_failed on that instance" do
        expect(mailer).to receive(:send_status_if_failed)
        subject
      end
    end
  end

  describe "instance methods" do
    let(:mailer){ described_class.new scenario_collection }
    let(:scenario_collection){ double FailureTracker::ScenarioCollection }

    describe "send_status_if_failed" do
      subject { mailer.send_status_if_failed }
      before { allow(mailer).to receive(:send_mail).and_return true }

      context "with failures" do
        let(:scenario_collection){ FailureTracker::ScenarioCollection.new [scenario1, scenario2] }
        let(:scenario1){ double FailureTracker::Scenario, failed?: false }
        let(:scenario2){ double FailureTracker::Scenario, failed?: true }

        it "should call send_mail" do
          expect(mailer).to receive(:send_mail)
          subject
        end
      end

      context "without failures" do
        let(:scenario_collection){ FailureTracker::ScenarioCollection.new [scenario1, scenario2] }
        let(:scenario1){ double FailureTracker::Scenario, failed?: false }
        let(:scenario2){ double FailureTracker::Scenario, failed?: false }

        it "should not call send_mail" do
          expect(mailer).to_not receive(:send_mail)
          subject
        end
      end
    end

    describe "send_mail" do
      subject { mailer.send_mail }
      let(:mail_subject){ "Hello world" }
      let(:body){ "<div>Hello world</div>" }
      before do
        allow(mailer).to receive(:subject).and_return mail_subject
        allow(mailer).to receive(:body).and_return body
      end

      it "should call MailxRuby" do
        expect(MailxRuby).to receive(:send_mail).with(body: body, subject: mail_subject, to: described_class::RECIPIENT, html: true)
        subject #mailer.send_mail
      end
    end

    describe "body" do
      subject { mailer.body }
      let(:body){ "<div>Hello world</div>" }
      let(:failed_scenarios){ double FailureTracker::ScenarioCollection }
      before do
        allow(FailureTracker::Formatters::MailFailureFormatter).to receive(:render).and_return body
        allow(mailer).to receive(:failed_scenarios).and_return failed_scenarios
      end

      it { is_expected.to eq body }

      it "should call formatter correctly" do
        expect(FailureTracker::Formatters::MailFailureFormatter).to receive(:render).with failed_scenarios
        subject
      end
    end

    describe "subject" do
      subject { mailer.subject }
      let(:worst_failure_type){ "catastrophic_outage" }
      let(:failed_scenarios){ double FailureTracker::ScenarioCollection }
      before do
        allow(mailer).to receive(:failed_scenarios).and_return failed_scenarios
        allow(failed_scenarios).to receive(:worst_failure_type).and_return worst_failure_type
      end

      it { is_expected.to eq "Browbeat: catastrophic outage detected" }
    end

    describe "failed_scenarios" do
      describe "with scenarios" do
        subject { mailer.failed_scenarios }
        let(:scenario_collection){ FailureTracker::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4] }
        let(:scenario1){ double FailureTracker::Scenario, failed?: false }
        let(:scenario2){ double FailureTracker::Scenario, failed?: true }
        let(:scenario3){ double FailureTracker::Scenario, failed?: true }
        let(:scenario4){ double FailureTracker::Scenario, failed?: false }

        it { is_expected.to match_array [scenario2, scenario3] }
        it { is_expected.to be_a FailureTracker::ScenarioCollection }
      end

      describe "without scenarios" do
        subject { mailer.failed_scenarios }
        let(:scenario_collection){ FailureTracker::ScenarioCollection.new [] }

        it { is_expected.to match_array [] }
        it { is_expected.to be_a FailureTracker::ScenarioCollection }
      end
    end
  end
end

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
        before { allow(mailer).to receive(:any_failures?).and_return true }

        it "should call send_mail" do
          expect(mailer).to receive(:send_mail)
          subject
        end

        it "should not call previously_failing?" do
          expect(FailureTracker::StatusSync).to_not receive(:previously_failing?)
          subject
        end
      end

      context "without failures" do
        before { allow(mailer).to receive(:any_failures?).and_return false }

        context "without scenarios" do
          let(:scenario_collection){ FailureTracker::ScenarioCollection.new [] }

          it "should not call send_mail" do
            expect(mailer).to_not receive(:send_mail)
            subject
          end

          it "should call previously_failing? correctly" do
            expect(FailureTracker::StatusSync).to receive(:previously_failing?).with([])
            subject
          end
        end

        context "with scenario applications" do
          let(:application1){ double FailureTracker::Scenario, status_page_id: "aaaa" }
          let(:application2){ double FailureTracker::Scenario, status_page_id: "bbbb" }
          let(:application3){ double FailureTracker::Scenario, status_page_id: "cccc" }
          before { allow(mailer).to receive(:scenario_applications).and_return [application1, application2, application3] }

          context "with previous failures" do
            before { allow(FailureTracker::StatusSync).to receive(:previously_failing?).and_return true }

            it "should call send_mail" do
              expect(mailer).to receive(:send_mail)
              subject
            end

            it "should call previously_failing? correctly" do
              expect(FailureTracker::StatusSync).to receive(:previously_failing?).with(["aaaa", "bbbb", "cccc"])
              subject
            end
          end

          context "without previous failures" do
            before { allow(FailureTracker::StatusSync).to receive(:previously_failing?).and_return false }

            it "should not call send_mail" do
              expect(mailer).to_not receive(:send_mail)
              subject
            end

            it "should call previously_failing? correctly" do
              expect(FailureTracker::StatusSync).to receive(:previously_failing?).with(["aaaa", "bbbb", "cccc"])
              subject
            end
          end
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

      context "with FAILURE_EMAIL_RECIPIENT set" do
        around do |example|
          with_modified_env FAILURE_EMAIL_RECIPIENT: 'joe@example.com' do
            example.run
          end
        end

        it "should call MailxRuby" do
          expect(MailxRuby).to receive(:send_mail).with(body: body, subject: mail_subject, to: 'joe@example.com', html: true)
          subject
        end
      end

      context "with FAILURE_EMAIL_RECIPIENT not set" do
        around do |example|
          with_modified_env FAILURE_EMAIL_RECIPIENT: nil do
            example.run
          end
        end

        it "should print a warning" do
          expect(mailer).to receive(:puts).with("WARNING: No email sent since FAILURE_EMAIL_RECIPIENT is not specified")
          expect(MailxRuby).to_not receive(:send_mail)
          subject
        end
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

      context "with failures" do
        before { allow(mailer).to receive(:any_failures?).and_return true }

        it { is_expected.to eq body }

        it "should call formatter correctly" do
          expect(FailureTracker::Formatters::MailFailureFormatter).to receive(:render).with failed_scenarios
          subject
        end
      end

      context "without failures" do
        before { allow(mailer).to receive(:any_failures?).and_return false }

        it { is_expected.to eq "Some services were previously set to failing, but Browbeat found them operational." }

        it "should not call formatter" do
          expect(FailureTracker::Formatters::MailFailureFormatter).to_not receive(:render)
          subject
        end
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

      context "with failures" do
        before { allow(mailer).to receive(:any_failures?).and_return true }

        it { is_expected.to eq "Browbeat: catastrophic outage detected" }
      end

      context "without failures" do
        before { allow(mailer).to receive(:any_failures?).and_return false }

        it { is_expected.to eq "Browbeat: services now operational" }
      end
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

    describe "any_failures?" do
      subject { mailer.any_failures? }
      context "with failing scenarios" do
        let(:scenario_collection){ FailureTracker::ScenarioCollection.new [scenario1, scenario2] }
        let(:scenario1){ double FailureTracker::Scenario, failed?: false }
        let(:scenario2){ double FailureTracker::Scenario, failed?: true }

        it { is_expected.to be_truthy }
      end

      context "without failing scenarios" do
        let(:scenario_collection){ FailureTracker::ScenarioCollection.new [scenario1, scenario2] }
        let(:scenario1){ double FailureTracker::Scenario, failed?: false }
        let(:scenario2){ double FailureTracker::Scenario, failed?: false }

        it { is_expected.to be_falsy }
      end

      context "without scenarios" do
        let(:scenario_collection){ FailureTracker::ScenarioCollection.new [] }

        it { is_expected.to be_falsy }
      end
    end

    describe "scenario_applications" do
      subject { mailer.scenario_applications }
      let(:scenario1){ double FailureTracker::Scenario, app_symbol: "aaaa" }
      let(:scenario2){ double FailureTracker::Scenario, app_symbol: "zzzz" }
      let(:scenario3){ double FailureTracker::Scenario, app_symbol: "xxxx" }
      let(:application1){ double FailureTracker::Application, symbol: "xxxx" }
      let(:application2){ double FailureTracker::Application, symbol: "yyyy" }
      let(:application3){ double FailureTracker::Application, symbol: "zzzz" }

      context "with scenarios" do
        let(:scenario_collection){ FailureTracker::ScenarioCollection.new [scenario1, scenario2, scenario3] }

        context "with applications" do
          before { allow(FailureTracker::Application).to receive(:list_all).and_return [application1, application2, application3] }

          it { is_expected.to match_array [application1, application3] }
        end

        context "without applications" do
          before { allow(FailureTracker::Application).to receive(:list_all).and_return [] }

          it { is_expected.to eq [] }
        end
      end

      context "without scenarios" do
        let(:scenario_collection){ FailureTracker::ScenarioCollection.new [] }

        context "with applications" do
          before { allow(FailureTracker::Application).to receive(:list_all).and_return [application1, application2, application3] }

          it { is_expected.to eq [] }
        end

        context "without applications" do
          before { allow(FailureTracker::Application).to receive(:list_all).and_return [] }

          it { is_expected.to eq [] }
        end
      end
    end

  end
end

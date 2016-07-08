require 'spec_helper'
require 'browbeat'

describe Browbeat::StatusMailer do
  describe "class methods" do
    describe "self.send_status" do
      subject { described_class.send_status scenario_collection }
      let(:mailer){ instance_double described_class }
      let(:scenario_collection){ instance_double Browbeat::ScenarioCollection }
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
    let(:scenario_collection){ instance_double Browbeat::ScenarioCollection }

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
          expect(Browbeat::StatusSync).to_not receive(:previously_failing?)
          subject
        end
      end

      context "without failures" do
        before { allow(mailer).to receive(:any_failures?).and_return false }

        context "without scenarios" do
          let(:scenario_collection){ Browbeat::ScenarioCollection.new [] }

          it "should not call send_mail" do
            expect(mailer).to_not receive(:send_mail)
            subject
          end

          it "should call previously_failing? correctly" do
            expect(Browbeat::StatusSync).to receive(:previously_failing?).with([])
            subject
          end
        end

        context "with scenario applications" do
          let(:application1){ instance_double Browbeat::Application, status_page_production_id: "aaaa", status_page_staging_id: "zzzz" }
          let(:application2){ instance_double Browbeat::Application, status_page_production_id: "bbbb", status_page_staging_id: "yyyy" }
          let(:application3){ instance_double Browbeat::Application, status_page_production_id: "cccc", status_page_staging_id: "xxxx" }
          before { allow(mailer).to receive(:scenario_applications).and_return [application1, application2, application3] }

          context "with previous production failures" do
            before do
              allow(Browbeat::StatusSync).to receive(:previously_failing?).and_return true
              allow(Browbeat::StatusSync).to receive(:previously_failing_on_staging?).and_return false
            end

            it "should call send_mail" do
              expect(mailer).to receive(:send_mail)
              subject
            end

            it "should call previously_failing? correctly" do
              expect(Browbeat::StatusSync).to receive(:previously_failing?).with(["aaaa", "bbbb", "cccc"])
              subject
            end
          end

          context "with previous staging failures" do
            before do
              allow(Browbeat::StatusSync).to receive(:previously_failing?).and_return false
              allow(Browbeat::StatusSync).to receive(:previously_failing_on_staging?).and_return true
            end

            it "should call send_mail" do
              expect(mailer).to receive(:send_mail)
              subject
            end

            it "should call previously_failing_on_staging? correctly" do
              expect(Browbeat::StatusSync).to receive(:previously_failing_on_staging?).with(["zzzz", "yyyy", "xxxx"])
              subject
            end
          end

          context "without previous failures" do
            before do
              allow(Browbeat::StatusSync).to receive(:previously_failing?).and_return false
              allow(Browbeat::StatusSync).to receive(:previously_failing_on_staging?).and_return false
            end

            it "should not call send_mail" do
              expect(mailer).to_not receive(:send_mail)
              subject
            end

            it "should call previously_failing? correctly" do
              expect(Browbeat::StatusSync).to receive(:previously_failing?).with(["aaaa", "bbbb", "cccc"])
              subject
            end

            it "should call previously_failing_on_staging? correctly" do
              expect(Browbeat::StatusSync).to receive(:previously_failing_on_staging?).with(["zzzz", "yyyy", "xxxx"])
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
      let(:failure_body){ "<div>Hello world</div>" }
      let(:success_body){ "<em>Hello world</em>" }
      let(:failed_scenarios){ instance_double Browbeat::ScenarioCollection }
      let(:applications){ instance_double Array }
      before do
        allow(Browbeat::Presenters::MailFailurePresenter).to receive(:render).and_return failure_body
        allow(Browbeat::Presenters::MailSuccessPresenter).to receive(:render).and_return success_body
        allow(mailer).to receive(:failed_scenarios).and_return failed_scenarios
        allow(mailer).to receive(:scenario_applications).and_return applications
      end

      context "with failures" do
        before { allow(mailer).to receive(:any_failures?).and_return true }

        it { is_expected.to eq failure_body }

        it "should call failure presenter correctly" do
          expect(Browbeat::Presenters::MailFailurePresenter).to receive(:render).with failed_scenarios, applications
          subject
        end
      end

      context "without failures" do
        before { allow(mailer).to receive(:any_failures?).and_return false }

        it { is_expected.to eq success_body }

        it "should call success presenter correctly" do
          expect(Browbeat::Presenters::MailSuccessPresenter).to receive(:render).with applications
          subject
        end
      end
    end

    describe "subject" do
      subject { mailer.subject }
      let(:worst_failure_type){ "catastrophic_outage" }
      let(:failed_scenarios){ instance_double Browbeat::ScenarioCollection }
      let(:production_scenarios){ instance_double Browbeat::ScenarioCollection }
      before do
        allow(mailer).to receive(:failed_scenarios).and_return failed_scenarios
        allow(failed_scenarios).to receive(:with_tags).and_return production_scenarios
        allow(production_scenarios).to receive(:worst_failure_type).and_return worst_failure_type
      end

      context "with failures" do
        before { allow(mailer).to receive(:any_failures?).and_return true }

        it { is_expected.to eq "Browbeat: catastrophic outage detected" }

        it "should call with_tags correctly" do
          expect(failed_scenarios).to receive(:with_tags).with(:production)
          subject
        end

        context "with no production failures" do
          before { allow(production_scenarios).to receive(:worst_failure_type).and_return nil }

          it { is_expected.to eq "Browbeat: staging outage detected" }
        end
      end

      context "without failures" do
        before { allow(mailer).to receive(:any_failures?).and_return false }

        it { is_expected.to eq "Browbeat: services now operational" }
      end
    end

    describe "failed_scenarios" do
      describe "with scenarios" do
        subject { mailer.failed_scenarios }
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4] }
        let(:scenario1){ instance_double Browbeat::Scenario, failed?: false }
        let(:scenario2){ instance_double Browbeat::Scenario, failed?: true }
        let(:scenario3){ instance_double Browbeat::Scenario, failed?: true }
        let(:scenario4){ instance_double Browbeat::Scenario, failed?: false }

        it { is_expected.to match_array [scenario2, scenario3] }
        it { is_expected.to be_a Browbeat::ScenarioCollection }
      end

      describe "without scenarios" do
        subject { mailer.failed_scenarios }
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [] }

        it { is_expected.to match_array [] }
        it { is_expected.to be_a Browbeat::ScenarioCollection }
      end
    end

    describe "any_failures?" do
      subject { mailer.any_failures? }
      context "with failing scenarios" do
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2] }
        let(:scenario1){ instance_double Browbeat::Scenario, failed?: false }
        let(:scenario2){ instance_double Browbeat::Scenario, failed?: true }

        it { is_expected.to be_truthy }
      end

      context "without failing scenarios" do
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2] }
        let(:scenario1){ instance_double Browbeat::Scenario, failed?: false }
        let(:scenario2){ instance_double Browbeat::Scenario, failed?: false }

        it { is_expected.to be_falsy }
      end

      context "without scenarios" do
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [] }

        it { is_expected.to be_falsy }
      end
    end

    describe "scenario_applications" do
      subject { mailer.scenario_applications }
      let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: "aaaa" }
      let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: "zzzz" }
      let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: "xxxx" }
      let(:application1){ instance_double Browbeat::Application, symbol: "xxxx" }
      let(:application2){ instance_double Browbeat::Application, symbol: "yyyy" }
      let(:application3){ instance_double Browbeat::Application, symbol: "zzzz" }
      let(:application_list){ Browbeat::ApplicationCollection.new(applications) }
      before do
        allow_any_instance_of(Browbeat::ApplicationCollection).to receive(:load_yml).and_return application_list
      end

      context "with scenarios" do
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3] }

        context "with applications" do
          let(:applications){ [application1, application2, application3] }

          it { is_expected.to match_array [application1, application3] }
        end

        context "without applications" do
          let(:applications){ [] }

          it { is_expected.to match_array [] }
        end
      end

      context "without scenarios" do
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [] }

        context "with applications" do
          let(:applications){ [application1, application2, application3] }

          it { is_expected.to match_array [] }
        end

        context "without applications" do
          let(:applications){ [] }

          it { is_expected.to match_array [] }
        end
      end
    end

  end
end

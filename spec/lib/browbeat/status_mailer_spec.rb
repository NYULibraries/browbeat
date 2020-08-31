require 'spec_helper'
require 'browbeat'

describe Browbeat::StatusMailer do
  describe "class methods" do
    describe "self.send_status" do
      subject { described_class.send_status scenario_collection, application_collection }
      let(:mailer){ instance_double described_class }
      let(:scenario_collection){ instance_double Browbeat::ScenarioCollection }
      let(:application_collection){ instance_double Browbeat::ApplicationCollection }
      let(:return_val) { "fake val" }
      before do
        allow(described_class).to receive(:new).and_return mailer
        allow(mailer).to receive(:send_status_if_failed).and_return return_val 
      end

      it "should instantiate instance correctly" do
        expect(described_class).to receive(:new).with scenario_collection, application_collection
        subject
      end

      it "should call send_status_if_failed on that instance" do
        expect(mailer).to receive(:send_status_if_failed)
        subject
      end

      it { is_expected.to eq return_val }
    end
  end

  describe "instance methods" do
    let(:mailer){ described_class.new scenario_collection, application_collection }
    let(:scenario_collection){ instance_double Browbeat::ScenarioCollection }
    let(:application_collection){ instance_double Browbeat::ApplicationCollection }

    describe "send_status_if_failed" do
      subject { mailer.send_status_if_failed }
      let(:return_val){ "some val" }
      before do
        allow(mailer).to receive(:send_mail).and_return return_val 
        allow(mailer).to receive(:puts).and_return true
      end

      context "with scenarios" do
        let(:scenario_collection){ Browbeat::ScenarioCollection.new([double(Browbeat::Scenario)]) }

        around do |example|
          with_modified_env RECHECK: recheck do
            example.run
          end
        end

        context "with RECHECK unspecified" do
          let(:recheck){ nil }

          context "with failures" do
            before { allow(mailer).to receive(:any_failures?).and_return true }

            it "should call send_mail" do
              expect(mailer).to receive(:send_mail)
              subject
            end

            it { is_expected.to eq return_val }
          end

          context "without failures" do
            before { allow(mailer).to receive(:any_failures?).and_return false }

            context "with status page failures" do
              before { allow(mailer).to receive(:status_page_failures?).and_return true }

              it "should call send_mail" do
                expect(mailer).to receive(:send_mail)
                subject
              end

              it { is_expected.to eq return_val }
            end

            context "without status page failures" do
              before { allow(mailer).to receive(:status_page_failures?).and_return false }

              it "should not call send_mail" do
                expect(mailer).to_not receive(:send_mail)
                subject
              end

              it { is_expected.to eq true }
            end
          end # end "without failures"
        end # end "with RECHECK unspecified"

        context "with RECHECK specified" do
          let(:recheck){ 'true' }

          context "with all applications failing" do
            before { allow(mailer).to receive(:all_failures?).and_return true }

            it "should not call send_mail" do
              expect(mailer).to_not receive(:send_mail)
              subject
            end
            
            it { is_expected.to eq true }
          end

          context "with some applications failing" do
            before { allow(mailer).to receive(:all_failures?).and_return false }

            it "should call send_mail" do
              expect(mailer).to receive(:send_mail)
              subject
            end
            
            it { is_expected.to eq return_val }
          end
        end # end "with RECHECK specified"
      end

      context "without scenarios" do
        let(:scenario_collection){ Browbeat::ScenarioCollection.new([]) }

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
      let(:ses){ instance_double Aws::SES::Client }
      let(:resp){ instance_double Aws::SES::Types::SendEmailResponse }
      let(:message_id){ "abcd1234" }
      before do
        allow(mailer).to receive(:subject).and_return mail_subject
        allow(mailer).to receive(:body).and_return body
        allow(mailer).to receive(:puts)
        allow(Aws::SES::Client).to receive(:new).and_return ses
        allow(resp).to receive(:message_id).and_return message_id
      end

      context "with FAILURE_EMAIL_RECIPIENT set" do
        around do |example|
          with_modified_env FAILURE_EMAIL_RECIPIENT: 'joe@example.com' do
            example.run
          end
        end
        before do
          allow(ses).to receive(:send_email).and_return resp
        end

        it "should send mail via Aws::SES::Client" do
          expect(mailer).to receive(:puts).with("Email sent! (#{message_id})")
          expect(ses).to receive(:send_email).with({
            destination: {
              to_addresses: [
                'joe@example.com',
              ],
            },
            message: {
              body: {
                html: {
                  charset: "UTF-8",
                  data: body,
                },
              },
              subject: {
                charset: "UTF-8",
                data: mail_subject,
              },
            },
            source: 'joe@example.com',
            })
          subject
        end

        it { is_expected.to eq true }
      end

      context "with FAILURE_EMAIL_RECIPIENT not set" do
        around do |example|
          with_modified_env FAILURE_EMAIL_RECIPIENT: nil do
            example.run
          end
        end

        it "should print a warning" do
          expect(mailer).to receive(:puts).with("WARNING: No email sent since FAILURE_EMAIL_RECIPIENT is not specified")
          expect(ses).to_not receive(:send_email)
          subject
        end

        it { is_expected.to eq false }
      end

    end

    describe "body" do
      subject { mailer.body }
      let(:failure_body){ "<div>Hello world</div>" }
      let(:success_body){ "<em>Hello world</em>" }
      let(:failed_scenarios){ instance_double Browbeat::ScenarioCollection }
      let(:applications){ instance_double Array }
      let(:environments){ instance_double Array }
      before do
        allow(Browbeat::Presenters::MailFailurePresenter).to receive(:render).and_return failure_body
        allow(Browbeat::Presenters::MailSuccessPresenter).to receive(:render).and_return success_body
        allow(mailer).to receive(:failed_scenarios).and_return failed_scenarios
        allow(mailer).to receive(:scenario_applications).and_return applications
        allow(mailer).to receive(:scenario_environments).and_return environments
      end

      context "with failures" do
        before { allow(mailer).to receive(:any_failures?).and_return true }

        it { is_expected.to eq failure_body }

        it "should call failure presenter correctly" do
          expect(Browbeat::Presenters::MailFailurePresenter).to receive(:render).with failed_scenarios, applications, environments
          subject
        end
      end

      context "without failures" do
        before { allow(mailer).to receive(:any_failures?).and_return false }

        it { is_expected.to eq success_body }

        it "should call success presenter correctly" do
          expect(Browbeat::Presenters::MailSuccessPresenter).to receive(:render).with applications, environments
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

    describe "all_failures?" do
      subject { mailer.all_failures? }

      context "with applications" do
        let(:application_collection){ Browbeat::ApplicationCollection.new [application1, application2] }
        let(:application1){ instance_double Browbeat::Application, symbol: 'abc' }
        let(:application2){ instance_double Browbeat::Application, symbol: 'def' }

        context "with at least one failing scenario each" do
          let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4] }
          let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: 'abc', failed?: true }
          let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: 'def', failed?: false }
          let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: 'abc', failed?: false }
          let(:scenario4){ instance_double Browbeat::Scenario, app_symbol: 'def', failed?: true }

          it { is_expected.to be_truthy }
        end

        context "with all failing scenarios" do
          let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4] }
          let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: 'abc', failed?: true }
          let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: 'def', failed?: true }
          let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: 'abc', failed?: true }
          let(:scenario4){ instance_double Browbeat::Scenario, app_symbol: 'def', failed?: true }

          it { is_expected.to be_truthy }
        end

        context "with only failing scenario for one app" do
          let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4] }
          let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: 'abc', failed?: true }
          let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: 'def', failed?: false }
          let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: 'abc', failed?: false }
          let(:scenario4){ instance_double Browbeat::Scenario, app_symbol: 'def', failed?: false }

          it { is_expected.to be_falsy }
        end

        context "with no failing scenarios" do
          let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3, scenario4] }
          let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: 'abc', failed?: false }
          let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: 'def', failed?: false }
          let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: 'abc', failed?: false }
          let(:scenario4){ instance_double Browbeat::Scenario, app_symbol: 'def', failed?: false }

          it { is_expected.to be_falsy }
        end

        context "with no scenarios" do
          let(:scenario_collection){ Browbeat::ScenarioCollection.new [] }

          it { is_expected.to be_falsy }
        end
      end

      context "without applications" do
        let(:application_collection){ Browbeat::ApplicationCollection.new [] }

        it { is_expected.to be_falsy }
      end


      # context "with some failing scenarios" do
      #   let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2, scenario3] }
      #   let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: 'abc', failed?: true }
      #   let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: 'def', failed?: true }
      #   let(:scenario3){ instance_double Browbeat::Scenario, app_symbol: 'abc', failed?: false }
      #
      #   it { is_expected.to be_falsy }
      # end
      #
      # context "without failing scenarios" do
      #   let(:scenario_collection){ Browbeat::ScenarioCollection.new [scenario1, scenario2] }
      #   let(:scenario1){ instance_double Browbeat::Scenario, app_symbol: 'abc', failed?: false }
      #   let(:scenario2){ instance_double Browbeat::Scenario, app_symbol: 'abc', failed?: false }
      #
      #   it { is_expected.to be_falsy }
      # end
      #
      # context "without scenarios" do
      #   let(:scenario_collection){ Browbeat::ScenarioCollection.new [] }
      #
      #   it { is_expected.to be_falsy }
      # end
    end

    describe "status_page_failures?" do
      subject { mailer.status_page_failures? }
      let(:production_component_list){ instance_double StatusPage::API::ComponentList, get: production_components }
      let(:staging_component_list){ instance_double StatusPage::API::ComponentList, get: staging_components }
      before do
        allow(StatusPage::API::ComponentList).to receive(:new).with(production_page_id).and_return production_component_list
        allow(StatusPage::API::ComponentList).to receive(:new).with(staging_page_id).and_return staging_component_list
        allow(mailer).to receive(:scenario_applications).and_return applications
        allow(mailer).to receive(:scenario_environments).and_return environments
      end

      context "with page ids defined" do
        let(:production_page_id){ "abcd" }
        let(:staging_page_id){ "wxyz" }

        around do |example|
          with_modified_env STATUS_PAGE_PAGE_ID: production_page_id, STATUS_PAGE_STAGING_PAGE_ID: staging_page_id do
            example.run
          end
        end

        context "with scenario applications" do
          let(:application1){ instance_double Browbeat::Application, status_page_production_id: "aaaa", status_page_staging_id: "zzzz" }
          let(:application2){ instance_double Browbeat::Application, status_page_production_id: "bbbb", status_page_staging_id: "yyyy" }
          let(:application3){ instance_double Browbeat::Application, status_page_production_id: "cccc", status_page_staging_id: "xxxx" }
          let(:applications){ [application1, application2, application3] }

          context "checking both environments" do
            let(:environments){ %w[production staging] }

            context "with matching, failing production components" do
              let(:production_component1){ instance_double StatusPage::API::Component, id: "cccc", failing?: false }
              let(:production_component2){ instance_double StatusPage::API::Component, id: "bbbb", failing?: true }
              let(:production_components){ [production_component1, production_component2] }
              let(:staging_components){ [] }

              it { is_expected.to eq true }
            end

            context "with non-matching, failing production components" do
              let(:production_component1){ instance_double StatusPage::API::Component, id: "abcd", failing?: false }
              let(:production_component2){ instance_double StatusPage::API::Component, id: "1234", failing?: true }
              let(:production_components){ [production_component1, production_component2] }

              context "without staging components" do
                let(:staging_components){ [] }

                it { is_expected.to eq false }
              end

              context "with matching, failing staging components" do
                let(:staging_component1){ instance_double StatusPage::API::Component, id: "xxxx", failing?: true }
                let(:staging_component2){ instance_double StatusPage::API::Component, id: "yyyy", failing?: false }
                let(:staging_components){ [staging_component1, staging_component2] }

                it { is_expected.to eq true }
              end

              context "with non-matching, failing staging components" do
                let(:staging_component1){ instance_double StatusPage::API::Component, id: "aaaa", failing?: true }
                let(:staging_component2){ instance_double StatusPage::API::Component, id: "abcd", failing?: false }
                let(:staging_components){ [staging_component1, staging_component2] }

                it { is_expected.to eq false }
              end

              context "with matching, operational staging components" do
                let(:staging_component1){ instance_double StatusPage::API::Component, id: "xxxx", failing?: false }
                let(:staging_component2){ instance_double StatusPage::API::Component, id: "yyyy", failing?: false }
                let(:staging_components){ [staging_component1, staging_component2] }

                it { is_expected.to eq false }
              end
            end

            context "with matching, operational production components" do
              let(:production_component1){ instance_double StatusPage::API::Component, id: "cccc", failing?: false }
              let(:production_component2){ instance_double StatusPage::API::Component, id: "bbbb", failing?: false }
              let(:production_components){ [production_component1, production_component2] }

              context "without staging components" do
                let(:staging_components){ [] }

                it { is_expected.to eq false }
              end

              context "with matching, failing staging components" do
                let(:staging_component1){ instance_double StatusPage::API::Component, id: "xxxx", failing?: true }
                let(:staging_component2){ instance_double StatusPage::API::Component, id: "yyyy", failing?: false }
                let(:staging_components){ [staging_component1, staging_component2] }

                it { is_expected.to eq true }
              end

              context "with non-matching, failing staging components" do
                let(:staging_component1){ instance_double StatusPage::API::Component, id: "aaaa", failing?: true }
                let(:staging_component2){ instance_double StatusPage::API::Component, id: "abcd", failing?: false }
                let(:staging_components){ [staging_component1, staging_component2] }

                it { is_expected.to eq false }
              end

              context "with matching, operational staging components" do
                let(:staging_component1){ instance_double StatusPage::API::Component, id: "xxxx", failing?: false }
                let(:staging_component2){ instance_double StatusPage::API::Component, id: "yyyy", failing?: false }
                let(:staging_components){ [staging_component1, staging_component2] }

                it { is_expected.to eq false }
              end
            end
          end

          context "checking only production" do
            let(:environments){ %w[production] }

            context "with matching, failing production components" do
              let(:production_component1){ instance_double StatusPage::API::Component, id: "cccc", failing?: false }
              let(:production_component2){ instance_double StatusPage::API::Component, id: "bbbb", failing?: true }
              let(:production_components){ [production_component1, production_component2] }
              let(:staging_components){ [] }

              it { is_expected.to eq true }
            end

            context "with non-matching, failing production components" do
              let(:production_component1){ instance_double StatusPage::API::Component, id: "abcd", failing?: false }
              let(:production_component2){ instance_double StatusPage::API::Component, id: "1234", failing?: true }
              let(:production_components){ [production_component1, production_component2] }

              context "without staging components" do
                let(:staging_components){ [] }

                it { is_expected.to eq false }
              end

              context "with matching, failing staging components" do
                let(:staging_component1){ instance_double StatusPage::API::Component, id: "xxxx", failing?: true }
                let(:staging_component2){ instance_double StatusPage::API::Component, id: "yyyy", failing?: false }
                let(:staging_components){ [staging_component1, staging_component2] }

                it { is_expected.to eq false }
              end
            end

            context "with matching, operational production components" do
              let(:production_component1){ instance_double StatusPage::API::Component, id: "cccc", failing?: false }
              let(:production_component2){ instance_double StatusPage::API::Component, id: "bbbb", failing?: false }
              let(:production_components){ [production_component1, production_component2] }

              context "without staging components" do
                let(:staging_components){ [] }

                it { is_expected.to eq false }
              end

              context "with matching, failing staging components" do
                let(:staging_component1){ instance_double StatusPage::API::Component, id: "xxxx", failing?: true }
                let(:staging_component2){ instance_double StatusPage::API::Component, id: "yyyy", failing?: false }
                let(:staging_components){ [staging_component1, staging_component2] }

                it { is_expected.to eq false }
              end
            end
          end
        end

        context "without scenario applications" do
          let(:applications){ [] }
          let(:environments){ %w[production staging] }

          context "with components" do
            let(:production_component1){ instance_double StatusPage::API::Component, id: "cccc", failing?: false }
            let(:production_component2){ instance_double StatusPage::API::Component, id: "bbbb", failing?: true }
            let(:staging_component1){ instance_double StatusPage::API::Component, id: "xxxx", failing?: true }
            let(:staging_component2){ instance_double StatusPage::API::Component, id: "yyyy", failing?: false }
            let(:production_components){ [production_component1, production_component2] }
            let(:staging_components){ [staging_component1, staging_component2] }

            it { is_expected.to eq false }
          end
        end
      end
    end

    describe "scenario_environments" do
      subject { mailer.scenario_environments }
      let(:production_scenario1){ instance_double Browbeat::Scenario }
      let(:production_scenario2){ instance_double Browbeat::Scenario }
      let(:staging_scenario1){ instance_double Browbeat::Scenario }

      before do
        allow(production_scenario1).to receive(:has_tag?).with('production').and_return true
        allow(production_scenario2).to receive(:has_tag?).with('production').and_return true
        allow(staging_scenario1).to receive(:has_tag?).with('production').and_return false
        allow(production_scenario1).to receive(:has_tag?).with('staging').and_return false
        allow(production_scenario2).to receive(:has_tag?).with('staging').and_return false
        allow(staging_scenario1).to receive(:has_tag?).with('staging').and_return true
      end

      context "with production and staging scenarios" do
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [production_scenario1, production_scenario2, staging_scenario1] }

        it { is_expected.to match_array %w[production staging] }
      end

      context "with only production scenarios" do
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [production_scenario1, production_scenario2] }

        it { is_expected.to match_array %w[production] }
      end

      context "with only staging scenarios" do
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [staging_scenario1] }

        it { is_expected.to match_array %w[staging] }
      end

      context "with no scenarios" do
        let(:scenario_collection){ Browbeat::ScenarioCollection.new [] }

        it { is_expected.to eq [] }
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
      let(:application_collection){ Browbeat::ApplicationCollection.new(applications) }

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

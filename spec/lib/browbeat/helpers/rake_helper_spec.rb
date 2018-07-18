require 'spec_helper'
require 'browbeat'

describe Browbeat::Helpers::RakeHelper do
  let(:helper){ Class.new{ extend Browbeat::Helpers::RakeHelper } }

  describe "tag_filtering" do
    subject { helper.tag_filtering }
    before do
      allow(helper).to receive(:specified_env).and_return specified_env
      allow(helper).to receive(:sauce_driver?).and_return sauce_driver?
    end

    context "with specified_env" do
      let(:specified_env){ "something" }

      context "with sauce driver" do
        let(:sauce_driver?){ true }

        it { is_expected.to eq "--tags @something --tags ~@no_sauce" }

        context "with specified tag" do
          subject { helper.tag_filtering('some_tag') }

          it { is_expected.to eq "--tags @something --tags ~@no_sauce --tags @some_tag" }
        end
      end

      context "without sauce driver" do
        let(:sauce_driver?){ false }

        it { is_expected.to eq "--tags @something" }

        context "with specified tag" do
          subject { helper.tag_filtering('some_tag') }

          it { is_expected.to eq "--tags @something --tags @some_tag" }
        end
      end
    end

    context "without specified_env" do
      let(:specified_env){ nil }

      context "with sauce driver" do
        let(:sauce_driver?){ true }

        it { is_expected.to eq "--tags ~@no_sauce" }

        context "with specified tag" do
          subject { helper.tag_filtering('some_tag') }

          it { is_expected.to eq "--tags ~@no_sauce --tags @some_tag" }
        end
      end

      context "without sauce driver" do
        let(:sauce_driver?){ false }

        it { is_expected.to eq "" }

        context "with specified tag" do
          subject { helper.tag_filtering('some_tag') }

          it { is_expected.to eq "--tags @some_tag" }
        end
      end
    end
  end

  describe "failing_application_features" do
    subject{ helper.failing_application_features }
    before do
      allow(helper).to receive(:failing_application_symbols).and_return failing_application_symbols
    end

    context "with failing_application_features" do
      let(:failing_application_symbols){ %w[abc efg xyz] }

      it { is_expected.to eq "features/abc/ping.feature features/abc/ features/efg/ping.feature features/efg/ features/xyz/ping.feature features/xyz/" }
    end

    context "with no failing_application_features" do
      let(:failing_application_symbols){ [] }

      it { is_expected.to eq "" }
    end
  end

  describe "failing_application_symbols" do
    subject{ helper.failing_application_symbols }
    before do
      allow(helper).to receive(:failing_applications).and_return failing_applications
    end

    context "with failing applications" do
      let(:application1){ instance_double Browbeat::Application, symbol: 'abc' }
      let(:application2){ instance_double Browbeat::Application, symbol: '123' }
      let(:application3){ instance_double Browbeat::Application, symbol: 'xyz' }
      let(:failing_applications){ Browbeat::ApplicationCollection.new [application1, application2, application3] }

      it { is_expected.to match_array %w[abc 123 xyz] }
    end

    context "without failing applications" do
      let(:failing_applications){ Browbeat::ApplicationCollection.new [] }

      it { is_expected.to match_array [] }
    end
  end

  describe "failing_applications" do
    subject{ helper.failing_applications }

    before do
      allow(helper).to receive(:applications).and_return applications
    end

    context "with failing applications" do
      let(:application1){ instance_double Browbeat::Application, status_page_production_component: production_component1, status_page_staging_component: staging_component1 }
      let(:application2){ instance_double Browbeat::Application, status_page_production_component: production_component2, status_page_staging_component: staging_component2 }
      let(:application3){ instance_double Browbeat::Application, status_page_production_component: production_component3, status_page_staging_component: staging_component3 }
      let(:application4){ instance_double Browbeat::Application, status_page_production_component: production_component4, status_page_staging_component: staging_component4 }
      let(:production_component1){ instance_double StatusPage::API::Component, failing?: false }
      let(:production_component2){ instance_double StatusPage::API::Component, failing?: true }
      let(:production_component3){ instance_double StatusPage::API::Component, failing?: false }
      let(:production_component4){ instance_double StatusPage::API::Component, failing?: true }
      let(:staging_component1){ instance_double StatusPage::API::Component, failing?: true }
      let(:staging_component2){ instance_double StatusPage::API::Component, failing?: false }
      let(:staging_component3){ instance_double StatusPage::API::Component, failing?: false }
      let(:staging_component4){ instance_double StatusPage::API::Component, failing?: true }
      let(:applications){ Browbeat::ApplicationCollection.new [application1, application2, application3, application4] }

      context "with all environments" do
        it { is_expected.to be_a Browbeat::ApplicationCollection }

        it { is_expected.to match_array [application1, application2, application4] }
      end

      context "with only staging environments" do
        before{ allow(helper).to receive(:all_environments).and_return %w[staging] }

        it { is_expected.to be_a Browbeat::ApplicationCollection }

        it { is_expected.to match_array [application1, application4] }
      end

      context "with only production environments" do
        before{ allow(helper).to receive(:all_environments).and_return %w[production] }

        it { is_expected.to be_a Browbeat::ApplicationCollection }

        it { is_expected.to match_array [application2, application4] }
      end
    end

    context "with only operational applications" do
      let(:application1){ instance_double Browbeat::Application, status_page_production_component: production_component1, status_page_staging_component: staging_component1 }
      let(:application2){ instance_double Browbeat::Application, status_page_production_component: production_component2, status_page_staging_component: staging_component2 }
      let(:application3){ instance_double Browbeat::Application, status_page_production_component: production_component3, status_page_staging_component: staging_component3 }
      let(:production_component1){ instance_double StatusPage::API::Component, failing?: false }
      let(:production_component2){ instance_double StatusPage::API::Component, failing?: false }
      let(:production_component3){ instance_double StatusPage::API::Component, failing?: false }
      let(:staging_component1){ instance_double StatusPage::API::Component, failing?: false }
      let(:staging_component2){ instance_double StatusPage::API::Component, failing?: false }
      let(:staging_component3){ instance_double StatusPage::API::Component, failing?: false }
      let(:applications){ Browbeat::ApplicationCollection.new [application1, application2, application3] }

      it { is_expected.to be_a Browbeat::ApplicationCollection }

      it { is_expected.to match_array [] }
    end

    context "with no applications" do
      let(:applications){ Browbeat::ApplicationCollection.new [] }

      it { is_expected.to be_a Browbeat::ApplicationCollection }

      it { is_expected.to match_array [] }
    end
  end

  describe "applications" do
    subject{ helper.applications }

    let(:application_collection){ instance_double Browbeat::ApplicationCollection, load_yml: partially_populated_application_collection }
    let(:partially_populated_application_collection){ instance_double Browbeat::ApplicationCollection, load_components: populated_application_collection }
    let(:populated_application_collection){ instance_double Browbeat::ApplicationCollection }
    before do
      allow(Browbeat::ApplicationCollection).to receive(:new).and_return application_collection
    end

    it { is_expected.to eq populated_application_collection }

    it "should call load_yml" do
      expect(application_collection).to receive(:load_yml)
      subject
    end

    it "should call load_components" do
      expect(partially_populated_application_collection).to receive(:load_components)
      subject
    end
  end

  describe "sauce_driver?" do
    subject{ helper.sauce_driver? }

    around do |example|
      with_modified_env DRIVER: driver do
        example.run
      end
    end

    context "when DRIVER=sauce" do
      let(:driver){ "sauce" }

      it { is_expected.to eq true }
    end

    context "when DRIVER is not sauce" do
      let(:driver){ "something" }

      it { is_expected.to eq false }
    end

    context "when DRIVER is not set" do
      let(:driver){ nil }

      it { is_expected.to eq false }
    end
  end
end

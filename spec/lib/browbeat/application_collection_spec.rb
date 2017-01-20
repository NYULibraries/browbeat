require 'spec_helper'
require 'browbeat'

describe Browbeat::ApplicationCollection do
  let(:collection){ described_class.new }

  describe "load_yml" do
    subject{ collection.load_yml }
    let(:yml){ "---\nlogin:\n  name: Login\n  status_page_production_id: abcd1234\n  status_page_staging_id: efgh9876\neshelf:\n  name: E-Shelf\n  status_page_production_id: wxyz1234\n  status_page_staging_id: vuts9876\n" }
    before do
      allow(File).to receive(:open).with(described_class::LIST_FILEPATH).and_return yml
    end

    it { is_expected.to match_array [subject[0], subject[1]] }

    it { is_expected.to eq collection }

    it "should have 2 items" do
      expect(subject.length).to eq 2
    end
    it "should have instances of the class" do
      expect(subject[0]).to be_a Browbeat::Application
      expect(subject[1]).to be_a Browbeat::Application
    end
    it "should initialize with correct yml" do
      expect(Browbeat::Application).to receive(:new).with(name: "Login", status_page_production_id: "abcd1234", status_page_staging_id: "efgh9876", symbol: "login")
      expect(Browbeat::Application).to receive(:new).with(name: "E-Shelf", status_page_production_id: "wxyz1234", status_page_staging_id: "vuts9876", symbol: "eshelf")
      subject
    end
  end

  describe "load_components" do
    subject{ collection.load_components }

    context "with members having status page ids" do
      let(:collection){ described_class.new [application1, application2, application3] }
      let(:application1){ Browbeat::Application.new name: "App 1", symbol: "app1", status_page_production_id: "aaaa", status_page_staging_id: "zzzz" }
      let(:application2){ Browbeat::Application.new name: "App 2", symbol: "app2", status_page_production_id: "bbbb", status_page_staging_id: "yyyy" }
      let(:application3){ Browbeat::Application.new name: "App 3", symbol: "app3", status_page_production_id: "cccc", status_page_staging_id: "xxxx" }

      context "with status page key and page IDs set" do
        let(:production_page_id){ "abcdefg" }
        let(:staging_page_id){ "tuvwxyz" }
        around do |example|
          with_modified_env STATUS_PAGE_PAGE_ID: production_page_id, STATUS_PAGE_STAGING_PAGE_ID: staging_page_id do
            example.run
          end
        end

        let(:production_component_list){ instance_double StatusPage::API::ComponentList, get: populated_production_component_list }
        let(:staging_component_list){ instance_double StatusPage::API::ComponentList, get: populated_staging_component_list }
        let(:populated_production_component_list){ instance_double StatusPage::API::ComponentList, to_a: production_components }
        let(:populated_staging_component_list){ instance_double StatusPage::API::ComponentList, to_a: staging_components }
        let(:production_components){ [production_component1, production_component2, production_component3, production_component4] }
        let(:production_component1){ instance_double StatusPage::API::Component, id: "bbbb" }
        let(:production_component2){ instance_double StatusPage::API::Component, id: "cccc" }
        let(:production_component3){ instance_double StatusPage::API::Component, id: "dddd" }
        let(:production_component4){ instance_double StatusPage::API::Component, id: "aaaa" }
        let(:staging_components){ [staging_component1, staging_component2, staging_component3, staging_component4] }
        let(:staging_component1){ instance_double StatusPage::API::Component, id: "wwww" }
        let(:staging_component2){ instance_double StatusPage::API::Component, id: "xxxx" }
        let(:staging_component3){ instance_double StatusPage::API::Component, id: "yyyy" }
        let(:staging_component4){ instance_double StatusPage::API::Component, id: "zzzz" }
        before do
          allow(StatusPage::API::ComponentList).to receive(:new).with(production_page_id).and_return production_component_list
          allow(StatusPage::API::ComponentList).to receive(:new).with(staging_page_id).and_return staging_component_list
          populated_production_component_list.instance_variable_set("@components", production_components)
          populated_staging_component_list.instance_variable_set("@components", staging_components)
        end

        it { is_expected.to eq collection }

        it "should assign production components" do
          subject
          expect(application1.status_page_production_component).to eq production_component4
          expect(application2.status_page_production_component).to eq production_component1
          expect(application3.status_page_production_component).to eq production_component2
        end

        it "should assign staging components" do
          subject
          expect(application1.status_page_staging_component).to eq staging_component4
          expect(application2.status_page_staging_component).to eq staging_component3
          expect(application3.status_page_staging_component).to eq staging_component2
        end
      end
    end
  end

  describe "select" do
    context "using name" do
      subject{ collection.select{|s| s.name == 'Test' } }
      let(:collection){ described_class.new applications }
      let(:application1){ instance_double Browbeat::Application, name: "Test" }
      let(:application2){ instance_double Browbeat::Application, name: "Test 1" }
      let(:application3){ instance_double Browbeat::Application, name: "Test 2" }

      context "with applications" do
        let(:applications){ [application1, application2, application3] }

        it { is_expected.to be_a described_class }
        it { is_expected.to match_array [application1] }
      end

      context "without applications" do
        let(:applications){ [] }

        it { is_expected.to be_a described_class }
        it { is_expected.to match_array [] }
      end
    end
  end

  describe "sort_by" do
    context "using symbol" do
      subject{ collection.sort_by(&:symbol) }
      let(:collection){ described_class.new applications }
      let(:application1){ instance_double Browbeat::Application, symbol: "def" }
      let(:application2){ instance_double Browbeat::Application, symbol: "ghi" }
      let(:application3){ instance_double Browbeat::Application, symbol: "abc" }

      context "with applications" do
        let(:applications){ [application1, application2, application3] }

        it{ is_expected.to be_a described_class }
        it "should order correctly" do
          expect(subject.to_a).to eq [application3, application1, application2]
        end
      end

      context "without applications" do
        let(:applications){ [] }

        it{ is_expected.to be_a described_class }
        it{ is_expected.to be_empty }
      end
    end
  end
end

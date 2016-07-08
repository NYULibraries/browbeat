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
end

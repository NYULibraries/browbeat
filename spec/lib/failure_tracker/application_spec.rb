require 'spec_helper'
require 'failure_tracker'

describe FailureTracker::Application do
  describe "class methods" do
    describe "self.list_all" do
      subject{ described_class.list_all }
      let(:yml){ "---\nlogin:\n  name: Login\n  status_page_id: abcd1234\neshelf:\n  name: E-Shelf\n  status_page_id: wxyz1234\n" }
      before do
        allow(File).to receive(:open).with(described_class::LIST_FILEPATH).and_return yml
      end

      it { is_expected.to be_an Array }
      it "should have 2 items" do
        expect(subject.length).to eq 2
      end
      it "should have instances of the class" do
        expect(subject[0]).to be_a described_class
        expect(subject[1]).to be_a described_class
      end
      it "should initialize with correct yml" do
        expect(described_class).to receive(:new).with(name: "Login", status_page_id: "abcd1234", symbol: "login")
        expect(described_class).to receive(:new).with(name: "E-Shelf", status_page_id: "wxyz1234", symbol: "eshelf")
        subject
      end
    end
  end

  describe "instance methods" do
    let(:name){ "Login" }
    let(:status_page_id){ "abcd1234" }
    let(:symbol){ "login" }
    let(:application){ described_class.new(name: name, status_page_id: status_page_id, symbol: symbol) }

    describe "set_status_page_status" do
      it "should call StatusPage with correct parameters" do
        expect(StatusPage).to receive(:set_component_status).with(status_page_id, "some_status")
        application.set_status_page_status "some_status"
      end
    end
  end
end

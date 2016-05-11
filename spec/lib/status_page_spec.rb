require 'spec_helper'
require 'status_page'

describe StatusPage do
  describe "set_component_status" do
    let(:component){ StatusPage::Component.new }
    let(:attributes){ ({"key"=>"val"}) }
    let(:subject){ StatusPage.set_component_status "getit", "major_outage" }
    before do
      allow(StatusPage::Component).to receive(:find_matching_name).and_return component
      allow(component).to receive(:update_status).and_return attributes
    end

    it "should find component matching name" do
      expect(StatusPage::Component).to receive(:find_matching_name).with("getit")
      subject
    end

    it "should execute update_status on that component" do
      expect(component).to receive(:update_status).with("major_outage")
      subject
    end

    it "should return attributes returned by update_status" do
      expect(subject).to eq attributes
    end

    context "when no matching component found" do
      before do
        allow(StatusPage::Component).to receive(:find_matching_name).and_return nil
      end

      it "should raise an error" do
        expect{ subject }.to raise_error "No component matching 'getit'"
      end
    end
  end
end

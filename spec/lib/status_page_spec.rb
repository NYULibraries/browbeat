require 'spec_helper'
require 'status_page'

describe StatusPage do
  describe "set_component_status" do
    subject{ StatusPage.set_component_status "abcd1234", "major_outage" }
    let(:component){ StatusPage::Component.new }
    let(:attributes){ ({"key"=>"val"}) }
    before do
      allow(StatusPage::Component).to receive(:find).and_return component
      allow(component).to receive(:update_status).and_return attributes
    end

    it "should find component matching name" do
      expect(StatusPage::Component).to receive(:find).with("abcd1234")
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
        allow(StatusPage::Component).to receive(:find).and_return nil
      end

      it "should raise an error" do
        expect{ subject }.to raise_error "No component with ID 'abcd1234'"
      end
    end
  end
end

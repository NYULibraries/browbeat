require 'spec_helper'
require 'status_page'

describe StatusPage::Component do
  let(:klass){ StatusPage::Component }
  let(:request){ StatusPage::Request }

  describe "class methods" do
    describe "self.list_all" do
      let(:subject){ klass.list_all }
      # stub out request
      let(:array_response) do
        [
          {"status"=>"operational", "name"=>"Library.nyu.edu", "id"=>"abcd"},
          {"status"=>"operational", "name"=>"E-Shelf", "id"=>"1234"},
          {"status"=>"operational", "name"=>"Login", "id"=>"wxyz"},
        ]
      end
      before do
        allow(request).to receive(:execute).and_return array_response
      end

      it "should execute request with correct parameters" do
        expect(request).to receive(:execute).with("components.json", method: :get)
        subject
      end

      it "should return an array of instances" do
        expect(subject).to be_an Array
        expect(subject.map(&:class).uniq).to eq [StatusPage::Component]
      end

      it "should initialize instances with attributes from response" do
        expect(klass).to receive(:new).with(array_response[0]).once.and_call_original
        expect(klass).to receive(:new).with(array_response[1]).once.and_call_original
        expect(klass).to receive(:new).with(array_response[2]).once.and_call_original
        subject
      end
    end

    describe "self.find_matching_name" do
      let(:component1){ klass.new({"status"=>"operational", "name"=>"Library.nyu.edu", "id"=>"abcd"}) }
      let(:component2){ klass.new({"status"=>"operational", "name"=>"E-Shelf app", "id"=>"1234"}) }
      let(:component3){ klass.new({"status"=>"operational", "name"=>"Login app", "id"=>"wxyz"}) }
      # stub out request
      before do
        allow(klass).to receive(:list_all).and_return [component1, component2, component3]
      end

      it "should return a component with a case-insensitive full matching name" do
        expect(klass.find_matching_name("library.nyu.edu")).to eq component1
      end

      it "should return a component with a case-insensitive partial, full-word matching name" do
        expect(klass.find_matching_name("e-shelF")).to eq component2
        expect(klass.find_matching_name("logIn")).to eq component3
      end

      it "should return nil even with a case-insensitive partial, partial-word matching name" do
        expect(klass.find_matching_name("library")).to eq nil
      end

      it "should return nil for a blank parameter" do
        expect(klass.find_matching_name("")).to eq nil
        expect(klass.find_matching_name(nil)).to eq nil
      end

      it "should raise an error for ambiguous match" do
        expect{ klass.find_matching_name("app") }.to raise_error "Ambiguous name 'app' matches multiple components: [\"E-Shelf app\", \"Login app\"]"
      end

    end
  end

  describe "instance methods" do
    let(:attributes){ ({"id"=>"abcd", "name"=>"favorite app", "status"=>"operational"}) }
    let(:component){ klass.new attributes }

    describe "id" do
      it "should return the id" do
        expect(component.id).to eq "abcd"
      end
    end

    describe "name" do
      it "should return the name" do
        expect(component.name).to eq "favorite app"
      end
    end

    describe "status" do
      it "should return the status" do
        expect(component.status).to eq "operational"
      end
    end

    describe "update_status" do
      before do
        allow(component).to receive(:update_attribute)
      end

      it "should execute update_attribute if given a valid status" do
        expect(component).to receive(:update_attribute).with(:status, "major_outage")
        component.update_status "major_outage"
      end

      it "should raise an error if given an invalid status" do
        expect{ component.update_status "xyz" }.to raise_error "Status 'xyz' not recognized. Valid statuses: [\"operational\", \"degraded_performance\", \"partial_outage\", \"major_outage\"]"
      end
    end

    describe "update_attribute" do
      let(:result_attributes){ attributes.merge("status"=>"major_outage", "something"=>"different") }
      before do
        allow(request).to receive(:execute).and_return result_attributes
      end

      it "should execute request with correct parameters" do
        expect(request).to receive(:execute).with("components/abcd.json", method: :patch, payload: "component[status]=major_outage")
        component.update_attribute :status, "major_outage"
      end

      it "should return result of execute" do
        expect(component.update_attribute :status, "major_outage").to eq result_attributes
      end

      it "should raise error if given unrecognized attribute name" do
        expect{ component.update_attribute :data, "new data" }.to raise_error "Attribute 'data' not recognized. Valid attributes: [\"name\", \"description\", \"status\"]"
      end
    end
  end
end
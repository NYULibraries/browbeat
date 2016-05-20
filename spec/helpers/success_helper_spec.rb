require 'yaml'
load 'features/support/helpers/success_helper.rb'

describe Browbeat::SuccessHelper do
  let(:helper){ Class.new { extend Browbeat::SuccessHelper } }

  describe "success_text_for" do
    let(:yml){ "---\nabc def: Hello World\nzyx wvu: hello Non-world\n" }
    before do
      allow(File).to receive(:open).and_return yml
    end

    it "should return the correct value for exact match" do
      expect(helper.success_text_for("zyx wvu")).to eq "hello Non-world"
    end

    it "should return the correct value for case-insensitive match" do
      expect(helper.success_text_for("aBc DeF")).to eq "Hello World"
    end

    it "should raise an error for a partial match" do
      expect{ helper.success_text_for("zYx") }.to raise_error /Success text for "zyx" is not defined/
    end

    it "should raise an error for a blank string" do
      expect{ helper.success_text_for("") }.to raise_error /Success text for "" is not defined/
    end
  end
end

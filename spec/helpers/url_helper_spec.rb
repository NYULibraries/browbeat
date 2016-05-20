require 'yaml'
load 'features/support/helpers/url_helper.rb'

describe Browbeat::UrlHelper do
  let(:helper){ Class.new { extend Browbeat::UrlHelper } }

  describe "url_to" do
    let(:yml){ "---\nabc def: url1\nzyx wvu: url2\n" }
    before do
      allow(File).to receive(:open).and_return yml
    end

    it "should return the correct value for exact match" do
      expect(helper.url_to("zyx wvu")).to eq "url2"
    end

    it "should return the correct value for case-insensitive match" do
      expect(helper.url_to("aBc DeF")).to eq "url1"
    end

    it "should raise an error for a partial match" do
      expect{ helper.url_to("zYx") }.to raise_error /URL "zyx" is not defined/
    end

    it "should raise an error for a blank string" do
      expect{ helper.url_to("") }.to raise_error /URL "" is not defined/
    end
  end
end

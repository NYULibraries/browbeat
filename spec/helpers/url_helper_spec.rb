require 'yaml'
load 'features/support/helpers/url_helper.rb'

describe Browbeat::UrlHelper do
  let(:helper){ Class.new { extend Browbeat::UrlHelper } }

  describe "url_to" do
    context "with URLS set" do
      let(:urls) do
        {
          "abc def" => "url1",
          "zyx wvu" => "url2",
        }
      end

      before do
        allow(File).to receive(:open).with("config/private/urls.yml").and_return urls.to_yaml 
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
end

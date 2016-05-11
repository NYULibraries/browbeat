require 'spec_helper'
require 'status_page'

describe StatusPage::Request do
  let(:helper){ StatusPage::Request }

  describe "execute" do
    context "with STATUS_PAGE_API_KEY" do
      # stub out api key env variable
      let(:status_page_api_key){ "XXXX" }
      around do |example|
        with_modified_env STATUS_PAGE_API_KEY: status_page_api_key do
          example.run
        end
      end

      context "given successful response" do
        # stub out request/response
        let(:response){ {"name"=>"apple", "id"=>"xyz"} }
        let(:json_response){ response.to_json }
        let(:url_result){ "https://api.statuspage.io/v1/pages/#{StatusPage::Request::PAGE_ID}/sample/path.json" }
        before do
          allow(RestClient::Request).to receive(:execute).and_return json_response
        end

        it "should call execute with URL generated from path" do
          expect(RestClient::Request).to receive(:execute).with(hash_including(url: url_result))
          helper.execute "sample/path.json", method: :get
        end

        it "should call execute with method specified" do
          expect(RestClient::Request).to receive(:execute).with(hash_including(method: :patch))
          helper.execute "sample/path.json", method: :patch
        end

        it "should raise error if no method specified" do
          expect{ helper.execute "sample/path.json" }.to raise_error ArgumentError
        end

        it "should call execute with any additional options specified" do
          expect(RestClient::Request).to receive(:execute).with(hash_including(option: :value, arr: [1,2]))
          helper.execute "sample/path.json", method: :patch, option: :value, arr: [1,2]
        end

        it "should return parsed json" do
          expect(JSON).to receive(:parse).with(json_response).and_call_original
          expect(helper.execute("sample/path.json", method: :patch)).to eq response
        end
      end

      context "given 422 response" do
        # stub out request/response
        let(:error){ RestClient::UnprocessableEntity.new }
        let(:json_response){ {"error" => ["Something went wrong"]}.to_json }
        before do
          allow(RestClient::Request).to receive(:execute).and_raise error
          allow(error).to receive(:response).and_return json_response
        end

        it "should raise validation error parsed from response" do
          expect{ helper.execute "sample/path.json", method: :patch }.to raise_error "Something went wrong"
        end
      end

      context "given other error response" do
        # stub out request/response
        let(:error){ RestClient::ResourceNotFound.new }
        before do
          allow(RestClient::Request).to receive(:execute).and_raise error
        end

        it "should raise the error" do
          expect{ helper.execute "sample/path.json", method: :patch }.to raise_error error
        end
      end
    end

    context "without STATUS_PAGE_API_KEY" do
      # stub out api key env variable
      around do |example|
        with_modified_env STATUS_PAGE_API_KEY: nil do
          example.run
        end
      end

      it "should raise an error without calling api" do
        expect(RestClient::Request).to_not receive(:execute)
        expect{ helper.execute "sample/path.json", method: :get }.to raise_error "Must specify STATUS_PAGE_API_KEY to use StatusPage"
      end
    end



  end
end

require 'spec_helper'
require 'browbeat'

describe Browbeat::Helpers::ScrubFigsHelper do
  let(:helper){ Class.new{ extend Browbeat::Helpers::ScrubFigsHelper } }

  describe "scrub_figs" do
    subject{ helper.scrub_figs(text) }

    context "without figs in text" do
      let(:text){ "Timed out waiting for response to {\"id\":\"2e975e3d-9db9-46ba-8c39-c07306eb8d91\",\"name\":\"click\",\"args\":[1,2]}. It's possible that this happened because something took a very long time (for example a page load was slow). If so, setting the Poltergeist :timeout option to a higher value will help (see the docs for details). If increasing the timeout does not help, this is probably a bug in Poltergeist - please report it to the issue tracker. (Capybara::Poltergeist::TimeoutError)" }

      it { is_expected.to eq text }
    end

    context "with URLS set" do
      let(:urls) do
        {
          "abc def" => "url1",
          "zyx wvu" => "url2",
        }
      end

      before do
        allow(Figs::ENV).to receive(:[]).with('URLS').and_return urls
      end

      context "and in text" do
        let(:text){ "Some error occurred when accessing url2" }

        it { is_expected.to eq "Some error occurred when accessing XXXXX" }
      end
    end

    context "with websolr SOLR_URL set" do
      let(:solr_url){ "www.example.com" }
      let(:websolr_conf) do
        {"SOLR_URL" => solr_url}
      end

      before do
        allow(Figs::ENV).to receive(:websolr).and_return websolr_conf
      end

      context "and in text" do
        let(:text){ "Couldn't access <www.example.com> (Capybara::Poltergeist::StatusFailError)" }

        it { is_expected.to eq "Couldn't access <XXXXX> (Capybara::Poltergeist::StatusFailError)" }
      end
    end

    context "with production SOLR_URL set" do
      let(:solr_url){ "www.abcdef.com/abcde" }
      let(:production_conf) do
        {"SOLR_URL" => solr_url}
      end

      before do
        allow(Figs::ENV).to receive(:production).and_return production_conf
      end

      context "and in text" do
        let(:text){ "Couldn't find <www.abcdef.com/abcde> (Capybara::Poltergeist::StatusFailError)" }

        it { is_expected.to eq "Couldn't find <XXXXX> (Capybara::Poltergeist::StatusFailError)" }
      end

      context "and not in text" do
        let(:text){ "Couldn't find <www.abcdef.com> (Capybara::Poltergeist::StatusFailError)" }

        it { is_expected.to eq "Couldn't find <www.abcdef.com> (Capybara::Poltergeist::StatusFailError)" }
      end
    end

    context "with passwords set" do
      let(:password1){ "123456" }
      let(:password2){ "qwerty" }
      let(:password3){ "xcvbnm" }
      let(:nyu_conf) do
        {
          "marli" => {"password" => password1},
          "staff" => {"password" => password2},
          "production_masters_student" => {"password" => password3},
        }
      end

      before do
        allow(Figs::ENV).to receive(:nyu).and_return nyu_conf
      end

      context "and in text" do
        let(:text){ "Couldn't find field '#password' when inputting 'qwerty' into field" }

        it { is_expected.to eq "Couldn't find field '#password' when inputting 'XXXXX' into field" }
      end

      context "and not in text" do
        let(:text){ "Couldn't find field '#password' when inputting 'qwert' into field" }

        it { is_expected.to eq "Couldn't find field '#password' when inputting 'qwert' into field" }
      end
    end
  end
end

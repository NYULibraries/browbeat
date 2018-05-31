require 'spec_helper'
require 'browbeat'

describe Browbeat::Helpers::ScrubFigsHelper do
  let(:helper){ Class.new{ extend Browbeat::Helpers::ScrubFigsHelper } }

  describe "scrub_figs" do
    subject{ helper.scrub_figs(text) }

    around do |example|
      with_modified_env SOME_VAR: 'not_a_secret', SHIBBOLETH_USERNAME: 'super_secret_username' do
        example.run
      end
    end

    context "without variables in text" do
      let(:text){ "Timed out waiting for response to {\"id\":\"2e975e3d-9db9-46ba-8c39-c07306eb8d91\",\"name\":\"click\",\"args\":[1,2]}. It's possible that this happened because something took a very long time (for example a page load was slow). If so, setting the Poltergeist :timeout option to a higher value will help (see the docs for details). If increasing the timeout does not help, this is probably a bug in Poltergeist - please report it to the issue tracker. (Capybara::Poltergeist::TimeoutError)" }

      it { is_expected.to eq text }
    end

    context "with non-listed environment variables in text" do
      let(:text){ "You entered 'not_a_secret' into the field" }

      it { is_expected.to eq "You entered 'not_a_secret' into the field" }
    end

    context "with listed environment variables in text" do
      let(:text){ "You entered 'super_secret_username' into the field" }

      it { is_expected.to eq "You entered 'XXXXX' into the field" }
    end
  end
end

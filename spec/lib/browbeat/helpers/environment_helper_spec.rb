require 'spec_helper'
require 'browbeat'

describe Browbeat::Helpers::EnvironmentHelper do
  let(:helper){ Class.new{ extend Browbeat::Helpers::EnvironmentHelper } }

  describe "all_environments" do
    subject { helper.all_environments }
    before { allow(helper).to receive(:specified_env).and_return specified_env }

    context "when specified_env is set" do
      let(:specified_env){ "something" }

      it { is_expected.to match_array %w[something] }
    end

    context "when specified_env is not set" do
      let(:specified_env){ nil }

      it { is_expected.to match_array %w[production staging] }
    end
  end

  describe "specified_env" do
    subject{ helper.specified_env }

    context "when BROWBEAT_ENV is set" do
      let(:browbeat_env){ "something" }

      around do |example|
        with_modified_env BROWBEAT_ENV: browbeat_env do
          example.run
        end
      end

      it { is_expected.to eq browbeat_env }
    end

    context "when BROWBEAT_ENV is not set" do
      around do |example|
        with_modified_env BROWBEAT_ENV: nil do
          example.run
        end
      end

      it { is_expected.to eq nil }
    end
  end
end

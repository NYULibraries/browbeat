require 'spec_helper'
require 'browbeat'

describe Browbeat::Presenters::MailSuccessPresenter do
  describe "class methods" do
    describe "self.render" do
      subject { described_class.render applications, environments }
      let(:presenter){ instance_double described_class }
      let(:applications){ [instance_double(Browbeat::Application), instance_double(Browbeat::Application)] }
      let(:environments){ %w[some_env another_env] }
      let(:result){ "<div>Hello!</div>" }
      before do
        allow(described_class).to receive(:new).and_return presenter
        allow(presenter).to receive(:render).and_return result
      end

      it { is_expected.to eq result }

      it "should instantiate instance correctly" do
        expect(described_class).to receive(:new).with applications, environments
        subject
      end

      it "should call render on that instance" do
        expect(presenter).to receive(:render)
        subject
      end
    end
  end

  describe "instance methods" do
    let(:presenter){ described_class.new applications, environments }
    let(:applications){ [instance_double(Browbeat::Application), instance_double(Browbeat::Application)] }
    let(:environments){ %w[production staging] }

    describe "render" do
      subject { presenter.render }
      let(:file_text){ "%div =environments" }
      let(:engine){ instance_double Haml::Engine }
      let(:result){ "Hello world!" }
      before do
        allow(File).to receive(:read).and_return file_text
        allow(Haml::Engine).to receive(:new).and_return engine
        allow(engine).to receive(:render).and_return result
      end

      it { is_expected.to eq result }

      it "should call File.read correctly" do
        expect(File).to receive(:read).with("lib/browbeat/templates/mail_success.html.haml")
        subject
      end

      it "should instantiate engine correctly" do
        expect(Haml::Engine).to receive(:new).with(file_text)
        subject
      end

      it "should call render correctly" do
        expect(engine).to receive(:render).with(presenter)
        subject
      end
    end

    describe "application_list" do
      subject { presenter.application_list }
      it { is_expected.to eq applications }
    end
  end
end

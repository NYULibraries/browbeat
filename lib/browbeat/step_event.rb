module Browbeat
  class StepEvent
    extend Forwardable
    delegate [:test_step, :test_case, :result] => :cucumber_event
    delegate [:action_location] => :test_step
    delegate [:failed?, :passed?, :pending?, :skipped?, :undefined?, :unknown?] => :result

    attr_accessor :cucumber_event, :cucumber_step

    def initialize(cucumber_event)
      @cucumber_event = cucumber_event
      @cucumber_step = test_step.source.detect{|s| s.is_a? Cucumber::Core::Ast::Step }
      raise("Nested step not found") if !cucumber_step && scenario_step?
    end

    def scenario_step?
      internal_source? && !internal_callback?
    end

    def name
      "#{cucumber_step.actual_keyword}#{cucumber_step.name}"
    end

    def status
      %i[failed passed pending skipped].detect do |status|
        public_send(:"#{status}?")
      end
    end

    private

    def filename
      test_step.location.file
    end

    def internal_source?
      filename.match(/\Afeatures\//)
    end

    def internal_callback?
      filename.match("features/support/callbacks.rb")
    end

  end
end

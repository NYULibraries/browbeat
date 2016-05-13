module FailureTracker
  class FailedScenarioCollection
    extend Forwardable
    delegate [:<<, :[], :first, :last, :map, :each, :to_a, :any?, :empty?, :include?] => :@failed_scenarios

    def initialize(failed_scenarios = [])
      @failed_scenarios = failed_scenarios
    end

    def with_tags(*tags)
      self.class.new to_a.select{|scenario| scenario.has_tags? *tags }
    end

    def group_by(*args, &block)
      to_a.group_by(*args, &block).map do |key, array|
        [key, self.class.new(array)]
      end.to_h
    end

    def worst_failure_type
      to_a.select(&:failure_severity).sort_by(&:failure_severity).first.failure_type if any?
    end


  end

end

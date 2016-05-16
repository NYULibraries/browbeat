module FailureTracker
  class FailedScenarioCollection
    extend Forwardable
    delegate [:<<, :[], :first, :last, :map, :each, :to_a, :any?, :empty?, :include?] => :@failed_scenarios

    def initialize(failed_scenarios = [])
      @failed_scenarios = failed_scenarios
    end

    # returns new instance whose constituent scenarios are those from the original with all of the given tags
    def with_tags(*tags)
      self.class.new to_a.select{|scenario| scenario.has_tags? *tags }
    end

    # returns worst failure type from all constituent scenarios
    def worst_failure_type
      to_a.select(&:failure_severity).sort_by(&:failure_severity).first.failure_type if any?
    end

    # wrapper for Array#select that returns instance of this class
    def select(&block)
      self.class.new to_a.select(&block)
    end

    # wrapper for Array#group_by; returned hash's values are instances of this class (instead of Arrays)
    def group_by(*args, &block)
      to_a.group_by(*args, &block).map do |key, array|
        [key, self.class.new(array)]
      end.to_h
    end

  end

end

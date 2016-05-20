module FailureTracker
  class ScenarioCollection
    extend Forwardable
    delegate [:<<, :[], :first, :last, :map, :each, :to_a, :to_ary, :any?, :none?, :empty?, :include?] => :@scenarios

    def initialize(scenarios = [])
      @scenarios = scenarios
    end

    # returns new instance whose constituent scenarios are those from the original with all of the given tags
    def with_tags(*tags)
      self.class.new @scenarios.select{|scenario| scenario.has_tags? *tags }
    end

    # returns worst failure type from all constituent scenarios
    def worst_failure_type
      @scenarios.select(&:failure_severity).sort_by(&:failure_severity).first.failure_type if any?
    end

    # wrapper for Array#select that returns instance of this class
    def select(&block)
      self.class.new @scenarios.select(&block)
    end

    # wrapper for Array#group_by; returned hash's values are instances of this class (instead of Arrays)
    def group_by(*args, &block)
      @scenarios.group_by(*args, &block).map do |key, array|
        [key, self.class.new(array)]
      end.to_h
    end

  end

end

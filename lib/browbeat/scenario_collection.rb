module Browbeat
  class ScenarioCollection < CollectionBase

    # returns new instance whose constituent scenarios are those from the original with all of the given tags
    def with_tags(*tags)
      self.class.new @members.select{|scenario| scenario.has_tags?(*tags) }
    end

    # returns worst failure type from all constituent scenarios
    def worst_failure_type
      @members.select(&:failure_severity).sort_by(&:failure_severity).first.failure_type if any?(&:failure_severity)
    end
  end

end

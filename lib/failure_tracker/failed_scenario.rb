module FailureTracker
  class FailedScenario
    extend Forwardable
    delegate [:name, :steps, :file, :source_tag_names] => :cucumber_scenario
    delegate [:backtrace_line] => :failed_step

    ORDERED_FAILURE_TYPES = %w[major_outage partial_outage degraded_performance]
    ENVIRONMENTS = %w[production staging]

    def initialize(cucumber_scenario)
      @cucumber_scenario = cucumber_scenario
    end

    def cucumber_scenario
      @cucumber_scenario
    end

    # returns failure type as indicated by tags
    def failure_type
      @failure_type ||= find_match_in_tags(ORDERED_FAILURE_TYPES)
    end

    # returns integer for severity of failure; lower numbers are more severe
    def failure_severity
      ORDERED_FAILURE_TYPES.index(failure_type)
    end

    # returns app name as indicated by file path
    def app_name
      @app_name ||= file.match(/^features\/([\w-]+)\//)[1]
    end

    # returns cucumber step at which failure occurred
    def failed_step
      @failed_step ||= steps.detect{|s| s.status == :failed }
    end

    def has_tags?(*tags)
      tags.all?{|t| has_tag?(t) }
    end

    # returns true if has tag; accepts strings and symbols, with or without preceding '@'
    def has_tag?(tag)
      source_tag_names.any?{|t| t.match(/^@?#{tag}$/i) }
    end

    private
    def find_match_in_tags(possible_matches)
      possible_matches.detect do |value|
        has_tag? value
      end
    end

  end

end

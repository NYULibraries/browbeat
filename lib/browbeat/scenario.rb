module Browbeat
  class Scenario
    extend Forwardable
    delegate [:name, :exception, :tags, :status, :failed?, :passed?] => :cucumber_scenario
    delegate [:backtrace] => :exception

    attr_accessor :cucumber_scenario, :step_events

    ORDERED_FAILURE_TYPES = %w[major_outage partial_outage degraded_performance warning]
    ENVIRONMENTS = %w[production staging]

    def initialize(cucumber_scenario, step_events)
      @cucumber_scenario = cucumber_scenario
      @step_events = step_events || raise(ArgumentError, "step_events may not be nil")
    end

    def tag_names
      @tag_names ||= tags.map(&:name)
    end

    def features_backtrace
      backtrace.select{|trace| trace.match(features_filepath_regex) }
    end

    def file
      return @file if @file
      if match_data = cucumber_scenario.inspect.match(/(features\/.+):/)
        @file = match_data[1]
      else
        raise("File path could not be found from regex")
      end
    end

    # if scenario failing, returns failure type as indicated by tags
    def failure_type
      @failure_type ||= find_match_in_tags(ORDERED_FAILURE_TYPES) if failed?
    end

    # returns integer for severity of failure; lower numbers are more severe
    def failure_severity
      ORDERED_FAILURE_TYPES.index(failure_type)
    end

    # returns app name as indicated by file path
    def app_symbol
      @app_symbol ||= file.match(/^features\/([\w-]+)\//)[1]
    end

    def exception_message
      "#{exception.message} (#{exception})"
    end

    def has_tags?(*tags)
      tags.all?{|t| has_tag?(t) }
    end

    # returns true if has tag; accepts strings and symbols, with or without preceding '@'
    def has_tag?(tag)
      tag_names.any?{|t| t.match(/^@?#{tag}$/i) }
    end

    private
    def find_match_in_tags(possible_matches)
      possible_matches.detect do |value|
        has_tag? value
      end
    end

    def features_filepath_regex
      /#{Dir.glob("features/*").join("|")}/
    end

  end

end

module Browbeat
  module GetitHelper
    def first_result_matching(text)
      first('.results .result', text: text)
    end

    def first_umlaut_section_matching(text)
      first('.umlaut-section', text: text)
    end

    # captures a new window object opened by block for use with within_new_window
    def capture_new_window(&block)
      @@new_window = window_opened_by &block
    end

    # executes given block within new window captured by capture_new_window
    def within_new_window(&block)
      raise "Must capture_new_window before calling within_new_window" unless @@new_window
      within_window @@new_window, &block
    end
  end
end

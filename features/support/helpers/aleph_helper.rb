module Browbeat
  module AlephHelper
    def first_aleph_result_matching(text)
      first('table tr', text: /#{text}/i)
    end
  end
end

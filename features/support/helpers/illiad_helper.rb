module Browbeat
  module IlliadHelper
    def curl_result(url)
      `curl -vs "#{url}" 2>&1`
    end
  end
end

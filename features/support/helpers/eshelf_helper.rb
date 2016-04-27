module Browbeat
  module EshelfHelper
    def passive_login_path
      '/login/passive'
    end

    def first_result
      first('.results .result')
    end
  end
end

module Browbeat
  module PrivilegesHelper
    def privileges_dropdown
      'sublibrary_code'
    end

    def privileges_table
      find('#permissions_chart table')
    end
  end
end

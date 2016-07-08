module Browbeat
  module Helpers
    module ApiPageIdsHelper
      def status_page_page_id
        ENV['STATUS_PAGE_PAGE_ID'] || raise("Must specify STATUS_PAGE_PAGE_ID")
      end

      def status_page_staging_page_id
        ENV['STATUS_PAGE_STAGING_PAGE_ID'] || raise("Must specify STATUS_PAGE_STAGING_PAGE_ID")
      end
    end
  end
end

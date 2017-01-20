module Browbeat
  module Helpers
    module StatusPagePresenterHelper
      def failing_on_status_page?(application)
        failing_on_production?(application) || failing_on_staging?(application)
      end

      def failing_on_production?(application)
        environments.include?('production') && application.status_page_production_component.failing?
      end

      def failing_on_staging?(application)
        environments.include?('staging') && application.status_page_staging_component.failing?
      end
    end
  end
end

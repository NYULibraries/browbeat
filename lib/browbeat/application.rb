module Browbeat
  class Application
    include Browbeat::Helpers::ApiPageIdsHelper

    attr_reader :name, :symbol, :status_page_production_id, :status_page_staging_id

    def initialize(name:, symbol:, status_page_production_id:, status_page_staging_id:)
      @name = name
      @symbol = symbol
      @status_page_production_id = status_page_production_id
      @status_page_staging_id = status_page_staging_id
    end

    # Usage to set production status:
    #   application.set_status_page_status 'major_outage'
    # to set staging status:
    #   application.set_status_page_status 'major_outage', environment: :staging
    def set_status_page_status(status_type, environment: :production)
      component = send("status_page_#{environment}_component")
      component.status = status_type
      component.save
    end

    def status_page_production_component
      @component ||= get_status_page_component(status_page_production_id, status_page_production_page_id)
    end

    def status_page_staging_component
      @staging_component ||= get_status_page_component(status_page_staging_id, status_page_staging_page_id)
    end

    private

    def get_status_page_component(component_id, page_id)
      comp = StatusPage::API::Component.new(component_id, page_id)
      comp.get
      comp
    end
  end
end

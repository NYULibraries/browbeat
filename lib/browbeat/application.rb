module Browbeat
  class Application
    LIST_FILEPATH = 'config/application_list.yml'

    attr_accessor :name, :symbol, :status_page_id, :status_page_staging_id

    def self.list_all
      all_applications_yaml.map do |app_symbol, attributes|
        new(**symbolize_keys(attributes).merge(symbol: app_symbol))
      end
    end

    def initialize(name:, symbol:, status_page_id:, status_page_staging_id:)
      @name = name
      @symbol = symbol
      @status_page_id = status_page_id
      @status_page_staging_id = status_page_staging_id
    end

    def set_status_page_status(status_type)
      status_page_component.status = status_type
      status_page_component.save
    end

    def set_status_page_staging_status(status_type)
      status_page_staging_component.status = status_type
      status_page_staging_component.save
    end

    def status_page_component
      @component ||= get_status_page_component
    end

    def status_page_staging_component
      @staging_component ||= get_status_page_staging_component
    end

    private

    def get_status_page_component
      comp = StatusPage::API::Component.new(status_page_id, status_page_page_id)
      comp.get
      comp
    end

    def get_status_page_staging_component
      comp = StatusPage::API::Component.new(status_page_staging_id, status_page_staging_page_id)
      comp.get
      comp
    end

    def status_page_page_id
      ENV['STATUS_PAGE_PAGE_ID'] || raise("Must define STATUS_PAGE_PAGE_ID")
    end

    def status_page_staging_page_id
      ENV['STATUS_PAGE_STAGING_PAGE_ID'] || raise("Must define STATUS_PAGE_STAGING_PAGE_ID")
    end

    def self.all_applications_yaml
      YAML.load File.open(LIST_FILEPATH){|f| f.read}
    end

    def self.symbolize_keys(hash)
      hash.map{|k,v| [k.to_sym, v] }.to_h
    end
  end
end

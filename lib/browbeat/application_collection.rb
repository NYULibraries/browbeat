module Browbeat
  class ApplicationCollection < CollectionBase
    include Browbeat::Helpers::ApiPageIdsHelper

    LIST_FILEPATH = 'config/application_list.yml'

    def load_yml
      @members = all_applications_yaml.map do |app_symbol, attributes|
        Application.new(**symbolize_keys(attributes).merge(symbol: app_symbol))
      end
      self
    end

    def load_components
      %w[production staging].each do |environment|
        load_components_for(environment)
      end
      self
    end

    private
    def all_applications_yaml
      YAML.load File.open(LIST_FILEPATH){|f| f.read}
    end

    def symbolize_keys(hash)
      hash.map{|k,v| [k.to_sym, v] }.to_h
    end
    
    def load_components_for(environment)
      components = StatusPage::API::ComponentList.new(send("status_page_#{environment}_page_id")).get.to_a
      each do |application|
        application.send("status_page_#{environment}_component=", components.detect{|c| c.id == application.send("status_page_#{environment}_id") })
      end
    end
  end
end

module Browbeat
  class ApplicationCollection < CollectionBase

    LIST_FILEPATH = 'config/application_list.yml'

    def load_yml
      @members = all_applications_yaml.map do |app_symbol, attributes|
        Application.new(**symbolize_keys(attributes).merge(symbol: app_symbol))
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
  end
end

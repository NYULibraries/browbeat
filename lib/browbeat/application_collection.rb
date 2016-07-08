module Browbeat
  class ApplicationCollection
    extend Forwardable
    delegate [:<<, :[], :first, :last, :map, :each, :to_a, :to_ary, :any?, :none?, :empty?, :include?, :length] => :@applications

    LIST_FILEPATH = 'config/application_list.yml'

    def initialize(applications = [])
      @applications = applications
    end

    def load_yml
      @applications = all_applications_yaml.map do |app_symbol, attributes|
        Application.new(**symbolize_keys(attributes).merge(symbol: app_symbol))
      end
      self
    end

    # wrapper for Array#select that returns instance of this class
    def select(&block)
      self.class.new @applications.select(&block)
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

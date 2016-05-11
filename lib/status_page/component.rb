module StatusPage
  class Component

    MUTABLE_ATTRIBUTES = %w[name description status]
    STATUSES = %w[operational degraded_performance partial_outage major_outage]

    def self.list_all
      StatusPage::Request.execute("components.json", method: :get).map do |external_attributes|
        new external_attributes
      end
    end

    # returns a component instance whose name matches given name; raises error if more than one components match
    def self.find_matching_name(name)
      matching = list_all.select{|c| c.name.match(/(^|\s)#{name}($|\s)/i) }
      matching.size < 2 ? matching[0] : raise("Ambiguous name '#{name}' matches multiple components: #{matching.map(&:name)}")
    end

    def initialize(external_attributes={})
      @attributes = external_attributes
    end

    def id
      @attributes["id"]
    end

    def name
      @attributes["name"]
    end

    def status
      @attributes["status"]
    end

    def update_status(status_type)
      validate_status status_type
      update_attribute :status, status_type
    end

    def update_attribute(attr_name, value)
      validate_attribute_name attr_name
      @attributes = StatusPage::Request.execute(
        "components/#{id}.json",
        method: :patch,
        payload: "component[#{attr_name}]=#{value}"
      )
    end

    private

    def validate_attribute_name(attr_name)
      MUTABLE_ATTRIBUTES.include?(attr_name.to_s) || raise("Attribute '#{attr_name}' not recognized. Valid attributes: #{MUTABLE_ATTRIBUTES}")
    end

    def validate_status(status_type)
      STATUSES.include?(status_type.to_s) || raise("Status '#{status_type}' not recognized. Valid statuses: #{STATUSES}")
    end

  end

end

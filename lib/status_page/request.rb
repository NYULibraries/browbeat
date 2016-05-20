module StatusPage
  class Request
    PAGE_ID = 'kyyfz4489y7m'

    # sends request to status page API for given path and method, passing any other options through to RestClient
    # parses the response and returns as a ruby hash or array
    def self.execute(path, method:, **options)
      default_options = {method: method, url: get_full_url(path), headers: authentication_headers}
      JSON.parse RestClient::Request.execute default_options.merge(options)
    rescue RestClient::UnprocessableEntity => e
      error_message = JSON.parse(e.response)["error"].join(", ")
      raise error_message
    end

    private

    def self.get_full_url(subpath)
      "https://api.statuspage.io/v1/pages/#{PAGE_ID}/#{subpath}"
    end

    def self.authentication_headers
      {'Authorization' => "OAuth #{api_key}"}
    end

    def self.api_key
      ENV['STATUS_PAGE_API_KEY'] || raise("Must specify STATUS_PAGE_API_KEY to use StatusPage")
    end

  end

end

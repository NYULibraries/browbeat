module Browbeat
  module UrlHelper
    URL_CONFIG_FILEPATH = 'config/urls.yml'

    # returns URL for given case-insensitive name as defined in YAML config file
    def url_to(url_name)
      url_name.downcase!
      url_hash[url_name] || raise("URL \"#{url_name}\" is not defined. Define it in #{URL_CONFIG_FILEPATH}")
    end

    def combine_url(*parts)
      File.join(*parts)
    end

    private
    def url_hash
      @@url_hash ||= read_url_hash
    end

    def read_url_hash
      YAML.load File.open(URL_CONFIG_FILEPATH){|f| f.read}
    end
  end
end

module Browbeat
  module UrlHelper
    # returns URL for given case-insensitive name as defined in URLS
    def url_to(url_name)
      url_name.downcase!
      url_hash[url_name] || raise("URL \"#{url_name}\" is not defined. Define it in #{url_path}")
    end

    def combine_url(*parts)
      File.join(*parts)
    end

    private
    def url_hash
      YAML.load(File.open(url_path){|f| f.read })
    end

    def url_path
      "config/private/urls.yml"
    end
  end
end

module Browbeat
  module UrlHelper
    # returns URL for given case-insensitive name as defined in URLS
    def url_to(url_name)
      url_name.downcase!
      url_hash[url_name] || raise("URL \"#{url_name}\" is not defined. Define it in URLS")
    end

    def combine_url(*parts)
      File.join(*parts)
    end

    private
    def url_hash
      Figs::ENV["URLS"] || {}
    end
  end
end

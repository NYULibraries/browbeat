module Browbeat
  module SpecialCollectionsHelper
    def special_collections_default_path
      "/search/"
    end

    def passive_login_path
      '/login/passive'
    end

    def finding_aid_base_url
      "http://dlib.nyu.edu/findingaids/html"
    end

    def special_collections_web_solr_url
      raise "Cannot access WebSolr URL while running tests in Sauce" if sauce_driver?
      Figs::ENV.production['SOLR_URL']
    end
  end
end

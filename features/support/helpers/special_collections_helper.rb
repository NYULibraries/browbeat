module Browbeat
  module SpecialCollectionsHelper
    def special_collections_default_path
      "/search"
    end

    def passive_login_url_regex
      /https:\/\/shibboleth\.nyu\.edu\/idp\/profile\/SAML2\/Redirect\/SSO\?SAMLRequest=.+/
    end

    def finding_aid_base_url
      "http://dlib.nyu.edu/findingaids/html"
    end
  end
end

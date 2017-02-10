module Browbeat
  module PrivilegesHelper
    def privileges_dropdown
      'sublibrary_code'
    end

    def privileges_table
      find('#permissions_chart table')
    end

    def privileges_web_solr_query_url
      File.join(privileges_web_solr_url, "select?q=test").to_s
    end

    private

    def privileges_web_solr_url
      raise "Cannot access WebSolr URL while running tests in Sauce" if sauce_driver?
      Figs::ENV.websolr['SOLR_URL']
    end
  end
end

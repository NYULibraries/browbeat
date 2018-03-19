module Browbeat
  module RoomsHelper
    def rooms_elasticsearch_url
      raise "Cannot access WebSolr URL while running tests in Sauce" if sauce_driver?
      Figs::ENV.bonsai['ROOMS_BONSAI_URL']
    end
  end
end

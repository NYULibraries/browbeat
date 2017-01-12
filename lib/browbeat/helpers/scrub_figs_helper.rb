module Browbeat
  module Helpers
    module ScrubFigsHelper
      def scrub_figs(text)
        configula_data.inject(text) do |result, datum|
          result.gsub(datum, 'X' * 10)
        end
      end

      private

      def configula_data
        Figs::ENV["URLS"].values + [Figs::ENV.websolr['SOLR_URL'], Figs::ENV.production['SOLR_URL'], Figs::ENV.nyu["marli"]["password"], Figs::ENV.nyu["staff"]["password"], Figs::ENV.nyu["production_masters_student"]["password"]]
      end
    end
  end
end

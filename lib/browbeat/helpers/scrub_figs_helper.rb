module Browbeat
  module Helpers
    module ScrubFigsHelper
      def scrub_figs(text)
        # binding.pry
        configula_data.inject(text) do |result, datum|
          result.gsub(datum, 'X' * 5)
        end
      end

      private

      def configula_data
        ((Figs::ENV["URLS"]&.values || []) + [
          Figs::ENV.websolr&.fetch('SOLR_URL'),
          Figs::ENV.production&.fetch('SOLR_URL'),
          Figs::ENV.nyu&.fetch('marli')&.fetch('password'),
          Figs::ENV.nyu&.fetch('staff')&.fetch('password'),
          Figs::ENV.nyu&.fetch('production_masters_student')&.fetch('password')
        ]).compact
      end
    end
  end
end

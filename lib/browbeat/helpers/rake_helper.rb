module Browbeat
  module Helpers
    module RakeHelper
      include EnvironmentHelper

      FEATURE_GROUPS = {
        primo: "Primo",
        login: "Login",
        eshelf: "e-Shelf",
        getit: "GetIt",
        aleph: "Aleph",
        arch: "Arch",
        special_collections: "Special Collections",
        privileges: "Privileges",
        website: "Library.nyu.edu website",
        marli: "MaRLi",
        illiad: "ILLiad",
        ezborrow: "EZBorrow",
        ezproxy: "EZProxy",
      }

      def tag_filtering
        [
          ("--tags @#{specified_env}" if specified_env),
          ("--tags ~@no_sauce" if sauce_driver?),
        ].compact.join(" ")
      end

      def failing_application_features
        failing_application_symbols.map do |directory|
          "features/#{directory}/ping.feature features/#{directory}/"
        end.join(" ")
      end

      def failing_application_symbols
        failing_applications.map(&:symbol)
      end

      def failing_applications
        applications.select do |application|
          all_environments.any? do |environment|
            application.send("status_page_#{environment}_component").failing?
          end
        end
      end

      def sauce_driver?
        ENV['DRIVER'] == 'sauce'
      end

      def applications
        @applications ||= ApplicationCollection.new.load_yml.load_components
      end
    end
  end
end

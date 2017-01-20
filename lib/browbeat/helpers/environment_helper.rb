module Browbeat
  module Helpers
    module EnvironmentHelper
      ENVIRONMENTS = %w[production staging]

      def all_environments
        specified_env ? [specified_env] : ENVIRONMENTS
      end

      def specified_env
        ENV['BROWBEAT_ENV']
      end

      def set_environment(env)
        ENV['BROWBEAT_ENV'] = env
      end
    end
  end
end

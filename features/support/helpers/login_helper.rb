module Browbeat
  module LoginHelper
    def shibboleth_username
      get_env_variable_or_raise 'SHIBBOLETH_USERNAME'
    end

    def shibboleth_password
      get_env_variable_or_raise 'SHIBBOLETH_PASSWORD'
    end

    def aleph_staging_username
      get_env_variable_or_raise 'ALEPH_STAGING_USERNAME'
    end

    def aleph_staging_password
      get_env_variable_or_raise 'ALEPH_STAGING_PASSWORD'
    end

    def get_env_variable_or_raise(variable_name)
      ENV[variable_name] || raise("Must specify #{variable_name} to run login features")
    end

    def login_default_path
      "/login"
    end
  end
end

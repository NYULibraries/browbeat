module Browbeat
  module LoginHelper
    def shibboleth_username
      Figs::ENV.nyu["production_staff"]["username"]
    end

    def shibboleth_password
      raise "Cannot access production Shibboleth password while running tests in Sauce" if ENV['DRIVER'] == 'sauce'
      Figs::ENV.nyu["production_staff"]["password"]
    end

    def shibboleth_staging_username
      Figs::ENV.nyu["staff"]["username"]
    end

    def shibboleth_staging_password
      Figs::ENV.nyu["staff"]["password"]
    end

    def get_env_variable_or_raise(variable_name)
      ENV[variable_name] || raise("Must specify #{variable_name} to run login features")
    end

    def login_default_path
      "/login"
    end

    def xml_body
      Nokogiri::XML page.body
    end
  end
end

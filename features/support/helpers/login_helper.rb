module Browbeat
  module LoginHelper
    def shibboleth_username
      ENV['SHIBBOLETH_USERNAME']
    end

    def shibboleth_password
      raise "Cannot access production Shibboleth password while running tests in Sauce" if sauce_driver?
      ENV['SHIBBOLETH_PASSWORD']
    end

    def shibboleth_staging_username
      ENV['SHIBBOLETH_STAGING_USERNAME']
    end

    def shibboleth_staging_password
      ENV['SHIBBOLETH_STAGING_PASSWORD']
    end

    def sauce_driver?
      ENV['DRIVER'] == 'sauce'
    end

    def login_default_path
      "/login"
    end

    def xml_body
      Nokogiri::XML(page.body)
    end
  end
end

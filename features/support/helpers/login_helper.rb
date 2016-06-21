module Browbeat
  module LoginHelper
    def shibboleth_username
      Figs::ENV.nyu["production_masters_student"]["username"]
    end

    def shibboleth_password
      raise "Cannot access production Shibboleth password while running tests in Sauce" if ENV['DRIVER'] == 'sauce'
      Figs::ENV.nyu["production_masters_student"]["password"]
    end

    def shibboleth_staging_username
      Figs::ENV.nyu["student"]["username"]
    end

    def shibboleth_staging_password
      Figs::ENV.nyu["student"]["password"]
    end

    def login_default_path
      "/login"
    end

    def xml_body
      Nokogiri::XML(page.body)
    end
  end
end

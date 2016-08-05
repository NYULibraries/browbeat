module Browbeat
  module MarliHelper
    def aleph_username
      Figs::ENV.nyu["marli"]["username"]
    end

    def aleph_password
      raise "Cannot access production Aleph password while running tests in Sauce" if sauce_driver?
      Figs::ENV.nyu["marli"]["password"]
    end

    def marli_default_path
      "/marli/"
    end
  end
end

module Browbeat
  module MarliHelper
    def aleph_username
      ENV['ALEPH_USERNAME']
    end

    def aleph_password
      raise "Cannot access production Aleph password while running tests in Sauce" if sauce_driver?
      ENV['ALEPH_PASSWORD']
    end

    def marli_default_path
      "/marli/"
    end
  end
end

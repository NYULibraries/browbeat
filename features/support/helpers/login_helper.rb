module Browbeat
  module LoginHelper
    def login_username
      ENV['LOGIN_USERNAME'] || raise("Must specify LOGIN_USERNAME to run login features")
    end

    def login_password
      ENV['LOGIN_PASSWORD'] || raise("Must specify LOGIN_PASSWORD to run login features")
    end

    def login_url
      "https://login.library.nyu.edu"
    end

    def login_staging_url
      "https://dev.login.library.nyu.edu"
    end

    def login_lb_server_1_url
      "https://login1.bobst.nyu.edu/"
    end

    def login_lb_server_2_url
      "https://login2.bobst.nyu.edu/"
    end

    def login_default_path
      "/login"
    end
  end
end

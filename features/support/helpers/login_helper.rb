module Browbeat
  module LoginHelper
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

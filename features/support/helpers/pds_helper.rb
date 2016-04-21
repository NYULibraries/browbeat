module Browbeat
  module PdsHelper
    def current_host
      URI::parse(current_url).host
    end

    def pds_url
      "https://pds.library.nyu.edu/pds?func=load-login&institute=NYU"
    end

    def pds_lb_server_1_url
      "https://primo1.bobst.nyu.edu/pds?func=load-login&institute=NYU"
    end

    def pds_lb_server_2_url
      "https://primo2.bobst.nyu.edu/pds?func=load-login&institute=NYU"
    end

    def pds_staging_url
      "https://pdsdev.library.nyu.edu/pds?func=load-login&institute=NYU"
    end

    def pds_staging_lb_server_1_url
      "https://primodev1.bobst.nyu.edu/pds?func=load-login&institute=NYU"
    end

    def pds_staging_lb_server_2_url
      "https://primodev2.bobst.nyu.edu/pds?func=load-login&institute=NYU"
    end
  end
end

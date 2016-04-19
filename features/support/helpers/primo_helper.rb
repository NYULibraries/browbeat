module Browbeat
  module PrimoHelper
    def bobcat_default_path
      "/primo_library/libweb/action/search.do"
    end

    # returns URL for given name; matches to _url methods in helper files
    # via case-insensitive match, e.g.:
    # url_to("BobCat") #=> bobcat_url
    # url_to("BobCat staging") #=> bobcat_staging_url
    def url_to(url_name)
      send(:"#{url_name.downcase.gsub(/\s+/,'_')}_url")
    end

    def bobcat_url
      "http://bobcat.library.nyu.edu/"
    end

    def bobcat_lb_server_1_url
      "http://primo1.bobst.nyu.edu/"
    end

    def bobcat_lb_server_2_url
      "http://primo2.bobst.nyu.edu/"
    end

    def bobcat_staging_url
      "http://bobcatdev.library.nyu.edu/"
    end

    def bobcat_staging_lb_server_1_url
      "http://primodev1.bobst.nyu.edu/"
    end

    def bobcat_staging_lb_server_2_url
      "http://primodev2.bobst.nyu.edu/"
    end

    def page_results
      page.find('.results')
    end

    def header_background_image
      page.evaluate_script('$("header").css("background-image")')
    end

    def logo_url_regex
      /url\(http:\/\/bobcat(dev)?\.library\.nyu\.edu\/primo_library\/libweb\/custom\/assets\/images\/nyulibraries\/nyu\/header\.png\?\d+\)/
    end
  end
end

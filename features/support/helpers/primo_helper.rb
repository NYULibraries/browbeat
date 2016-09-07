module Browbeat
  module PrimoHelper
    def bobcat_default_path
      "/primo_library/libweb/action/search.do"
    end

    def page_results
      page.find('.results')
    end

    def header_background_image
      page.evaluate_script('$("header").css("background-image")')
    end

    def logo_url_regex
      /url\("?http:\/\/bobcat(dev)?\.library\.nyu\.edu\/primo_library\/libweb\/custom\/assets\/images\/nyulibraries\/nyu\/header\.png\?\d+"?\)/
    end

    def first_result
      first('.results .result')
    end

    def page_institution_text
      page.evaluate_script("document.getElementsByClassName('institution')[0].textContent")
    end
  end
end

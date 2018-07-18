module Browbeat
  module PrimoHelper
    def bobcat_default_path
      "/primo_library/libweb/action/search.do"
    end

    # will be replaced by NUI version
    def page_results
      page.find('.results')
    end

    def nui_page_results
      page.find('#mainResults')
    end

    def header_background_image
      page.evaluate_script('$("header").css("background-image")')
    end

    def logo_url_regex
      /url\("?http:\/\/bobcat(dev)?\.library\.nyu\.edu\/primo_library\/libweb\/custom\/assets\/images\/nyulibraries\/nyu\/header\.png\?\d+"?\)/
    end

    # will be replaced by NUI version
    def first_result
      find('.results .result', match: :first)
    end

    def nui_first_result(text = nil)
      find('#mainResults .list-item-wrapper', match: :first, text: /#{text}/i)
    end

    def page_institution_text
      page.evaluate_script("document.getElementsByClassName('institution')[0].textContent")
    end
  end
end

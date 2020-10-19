module Browbeat
  module CurlHelper
    REDIRECT_HEADERS = ["HTTP/1.1 302 Moved temporarily", 'HTTP/1.1 302 Moved Temporarily', "HTTP/1.1 302 Found", "HTTP/1.1 301 Moved Permanently", "HTTP/1.1 302 Redirect"]

    def redirect_locations(url)
      curl_headers(url).select do |headers|
        (headers & REDIRECT_HEADERS).any?
        # %w[301 302].include?(get_status(headers))
      end.map do |headers|
        headers.detect{|h| h.match(/\ALocation\:/) }.gsub(/\ALocation\:/,'').gsub(/\/\z/,'').strip
      end
    end

    def initial_status(url, **options)
      get_status curl_headers(url, **options).first
    end

    def follow_redirect_status(url, **options)
      get_status curl_headers(url, **options).last
    end

    def file_downloaded(url)
      # raise "Status 200 fetching " unless follow_redirect_status(url) == "200"
      last_headers = curl_headers(url).last
      unless (status = get_status(last_headers)) == "200"
        raise "Unsuccessful status #{status} fetching file download at <#{url}>"
      end
      unless last_headers.include? "Content-Transfer-Encoding: binary"
        raise "Non-binary content while fetching file download at <#{url}>"
      end
      last_headers.detect do |header|
        match_data = header.match(/\AContent-Disposition: attachment; filename="(.+)"\z/)
        break match_data[1] if match_data
      end
    end

    def header_value(url, header_name, **options)
      last_headers = curl_headers(url).last
      if last_headers.grep(/\A#{header_name}:/).empty?
        raise "No #{header_name} header found in #{last_headers}"
      end
      last_headers.detect do |header|
        match_data = header.match(/\A#{header_name}: (.+)\z/)
        break match_data[1] if match_data
      end
    end

    private

    # curls the given URL, following any redirects; returns an array corresponding
    # to each successive request, with each element being another array of headers
    # in response for that request; so curl_headers(url)[0] gives an array of headers
    # for the first response, and curl_headers(url).last gives an array of headers
    # for the last response
    def curl_headers(url, insecure: false)
      `curl -sSL#{'k' if insecure} -o /dev/null -D - '#{url}' 2>&1`.split("\r\n\r\n").map{|x| x.split("\r\n") }
    end

    def get_status(headers)
      status_header = headers.detect do
        |h| h.match(/\AHTTP\/1\.1/) || h.match(/HTTP\/2/)
      end
      raise "No status header found in #{headers}" unless status_header
      status_header.match(/\d{3}/)[0]
    end
  end
end

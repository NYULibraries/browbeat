module Browbeat
  module CurlHelper


    # curls the given URL, following any redirects; returns an array corresponding
    # to each successive request, with each element being another array of headers
    # in response for that request; so curl_headers(url)[0] gives an array of headers
    # for the first response, and curl_headers(url).last gives an array of headers
    # for the last response
    def curl_headers(url, insecure: false)
      `curl -sSL#{'k' if insecure} -o /dev/null -D - #{url} 2>&1`.split("\r\n\r\n").map{|x| x.split("\r\n") }
    end

    def redirect_locations(url)
      curl_headers(url).select do |headers|
        # headers.include?("HTTP/1.1 302 Moved temporarily") || headers.include?("HTTP/1.1 302 Found")
        (headers & ["HTTP/1.1 302 Moved temporarily", "HTTP/1.1 302 Found", "HTTP/1.1 301 Moved Permanently"]).any?
      end.map do |headers|
        headers.detect{|h| h.match(/\ALocation\:/) }.gsub(/\ALocation\:/,'').gsub(/\/\z/,'').strip
      end
    end

    def get_status(status_code)
      {
        200 => "HTTP/1.1 200 OK",
        400 => "HTTP/1.1 400 Bad Request",
        302 => "HTTP/1.1 302 Found"
      }[status_code.to_i]
    end
  end
end

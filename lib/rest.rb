# frozen_string_literal: true

require 'httparty'
require 'json'
require 'uri'

require_relative 'exceptions/api_exception'

module Manticoresearch
  # RESTResponse class for handling REST API responses
  class RESTResponse
    attr_accessor :status, :data, :headers

    def initialize(response)
      @status = response.code
      @data = response.body
      @headers = response.headers
    end

    def getheaders
      @headers
    end

    def getheader(name, default_value = nil)
      normalized_headers = @headers.transform_keys(&:downcase)
      normalized_headers[name.downcase] || default_value
    end
  end

  # RESTClientObject class for making REST API requests
  class RESTClientObject
    # Initialize with a configuration
    def initialize(configuration)
      @configuration = configuration
      host = @configuration.host

      host = "http://#{host}" unless host =~ %r{\A\w+://}

      uri = URI.parse(host)
      host = uri.host || 'localhost'
      port = uri.port || 9308
      scheme = uri.scheme || 'http'

      @base_uri = "#{scheme}://#{host}:#{port}"
    end

    def request(method, url, query_params: nil, headers: {}, body: nil)
      full_url = URI.join(@base_uri, url).to_s

      options = {
        headers: headers
      }

      options[:query] = query_params if query_params && !query_params.empty?

      if body
        options[:body] = body.is_a?(String) ? body : body.to_json
        headers['Content-Type'] ||= 'application/json'
      end

      response = HTTParty.send(method.downcase, full_url, options)

      rest_response = RESTResponse.new(response)

      if rest_response.status < 200 || rest_response.status >= 300
        error_message = extract_error_message(response)
        raise ApiException.new(error_message, rest_response.status)
      end

      rest_response
    end

    private

    def extract_error_message(response)
      parsed_body = JSON.parse(response.body)
      parsed_body['error'] || "HTTP #{response.code}: #{response.message}"
    rescue JSON::ParserError
      "HTTP #{response.code}: #{response.message}"
    end
  end
end

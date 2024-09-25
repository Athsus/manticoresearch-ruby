# frozen_string_literal: true

require 'json'
require 'uri'
require_relative 'configuration'
require_relative 'rest'
require_relative 'exceptions/api_exception'

module Manticoresearch
  # ApiClient class for making HTTP requests
  class ApiClient
    attr_accessor :configuration, :default_headers, :cookie, :client_side_validation

    def initialize(configuration = Configuration.default, options = {})
      @configuration = configuration
      @client_side_validation = configuration.client_side_validation
      @cookie = options[:cookie]

      @default_headers = { 'User-Agent' => 'manticoresearch/ruby' }
      return unless options[:header_name] && options[:header_value]

      @default_headers[options[:header_name]] = options[:header_value]
    end

    # call the api
    # @param resource_path [String] The path to the API endpoint.
    # @param method [String] The HTTP method to use.
    # @param options [Hash] Additional options for the request.
    # @return [Hash] The parsed JSON response from the API.
    def call_api(resource_path, method, options = {})
      headers = prepare_headers(options[:header_params])
      full_url = build_full_url(resource_path, options[:path_params])
      response = RESTClientObject.new(@configuration).request(
        method, full_url, query_params: options[:query_params], headers: headers, body: options[:body]
      )
      # puts "call_api response, code is  #{response.status}, data is #{response.data}, headers is #{response.headers}"
      if response.status < 200 || response.status >= 300
        error_message = extract_error_message(response)
        raise Manticoresearch::ApiException.new(error_message, response.status)
      end
      JSON.parse(response.data)
    end

    # Select the appropriate Accept header
    def select_header_accept(accepts)
      return nil if accepts.empty?

      accepts.each do |accept|
        return accept if accept.downcase == 'application/json'
      end

      accepts.first
    end

    # Select the appropriate Content-Type header
    def select_header_content_type(content_types)
      return 'application/json' if content_types.empty?

      content_types.each do |content_type|
        return content_type if content_type.downcase == 'application/json'
      end

      content_types.first
    end

    private

    def prepare_headers(header_params)
      headers = @default_headers.dup
      headers.merge!(header_params) if header_params
      headers
    end

    def build_full_url(resource_path, path_params)
      full_url = @configuration.host + resource_path

      path_params&.each do |key, value|
        full_url.gsub!("{#{key}}", URI.encode_www_form_component(value))
      end
      full_url
    end

    def deserialize(data, _response_type = nil)
      JSON.parse(data)
    end

    def update_params_for_auth(headers, querys, auth_settings, request_auth = nil)
      # This method will update headers and query parameters based on authentication settings
      # Since specific authentication logic is not provided, this method can be left empty or implemented as needed
    end

    def sanitize_for_serialization(obj)
      sanitize_object(obj)
    end

    def sanitize_object(obj)
      case obj
      when Array
        obj.map { |item| sanitize_object(item) }
      when Hash
        obj.transform_values { |v| sanitize_object(v) }
      when Time
        obj.iso8601
      else
        obj
      end
    end

    def parameters_to_tuples(params)
      params.map { |k, v| [k, v.to_s] }
    end

    def files_parameters(files = nil)
      files ? files.map { |k, v| [k, v] } : []
    end

    def extract_error_message(response)
      # 尝试从响应中提取错误消息
      parsed_body = JSON.parse(response.data)
      parsed_body['error'] || "HTTP #{response.status}: #{response.reason}"
    rescue JSON::ParserError
      # 如果无法解析 JSON，则返回响应中的原始消息
      "HTTP #{response.status}: #{response.reason}"
    end
  end
end

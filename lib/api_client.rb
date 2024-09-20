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

    def close
      # close the rest client
    end

    def call_api(resource_path, method, options = {})
      headers = prepare_headers(options[:header_params])
      full_url = build_full_url(resource_path, options[:path_params])
      response = @rest.request(method, full_url, options[:query_params], headers, options[:body])
      deserialize(response.data, options[:response_type])
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

    def get_resp(url, headers = nil, query_params = nil)
      call_api(url, 'GET', nil, query_params, headers)
    end

    def post_resp(url, headers = nil, body = nil)
      call_api(url, 'POST', nil, nil, headers, body)
    end

    def put_resp(url, headers = nil, body = nil)
      call_api(url, 'PUT', nil, nil, headers, body)
    end

    def delete_resp(url, headers = nil, body = nil)
      call_api(url, 'DELETE', nil, nil, headers, body)
    end

    # 选择适当的 Accept 头
    def select_header_accept(accepts)
      return nil if accepts.empty?

      accepts.each do |accept|
        return accept if accept.downcase == 'application/json'
      end

      accepts.first
    end

    # 选择适当的 Content-Type 头
    def select_header_content_type(content_types)
      return 'application/json' if content_types.empty?

      content_types.each do |content_type|
        return content_type if content_type.downcase == 'application/json'
      end

      content_types.first
    end

    def update_params_for_auth(headers, querys, auth_settings, request_auth = nil)
      # 此方法将根据身份验证设置更新 headers 和查询参数
      # 由于具体的身份验证逻辑未提供，此处留空或根据需要实现
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
  end
end

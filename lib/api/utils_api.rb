# frozen_string_literal: true

require_relative '../api_client'
require_relative '../exceptions/api_exception'
require 'uri'
require 'json'

module Manticoresearch
  class UtilsApi
    def initialize(api_client = ApiClient.new)
      @api_client = api_client
    end

    # Executes an SQL query.
    # @param body [String] The SQL query to execute.
    # @param raw_response [Boolean, nil] Controls the format of the response.
    # @return [Hash, Array<Hash>] The response from the API.
    def sql(body, raw_response = nil)
      sql_with_http_info(body, raw_response: raw_response)
    end

    # Executes an SQL query with HTTP info.
    # @param body [String] The SQL query to execute.
    # @param raw_response [Boolean, nil] Controls the format of the response.
    # @return [Hash, Array<Hash>] The response from the API.
    def sql_with_http_info(body, raw_response: nil)
      # Ensure the 'body' parameter is provided
      raise ApiValueError, 'Missing the required parameter `body` when calling `sql`' unless body

      # Build query parameters
      query_params = {}
      query_params['raw_response'] = raw_response.to_s unless raw_response.nil?

      # Build body parameters based on 'raw_response'
      body_params = ''
      if raw_response == false
        body_params = 'query='
      elsif raw_response.nil? || raw_response == true
        body_params = 'mode=raw&query='
      end

      # URL-encode the 'body' parameter and append it to 'body_params'
      body_params += URI.encode_www_form_component(body)

      # Set header parameters
      header_params = {}
      header_accept = @api_client.select_header_accept(['application/json']) || 'application/json'
      header_params['Accept'] = header_accept

      header_content_type = @api_client.select_header_content_type(['text/plain']) || 'text/plain'
      header_params['Content-Type'] = header_content_type

      # Call the API, passing the URL-encoded body
      response = @api_client.call_api(
        '/sql',
        'POST',
        query_params: query_params,
        header_params: header_params,
        body: body_params
      )

      # Control the return format based on 'raw_response'
      raw_response == false ? [response] : response
    end
  end
end

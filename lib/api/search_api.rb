# frozen_string_literal: true

require_relative '../api_client'
require_relative '../exceptions/api_exception'
require 'uri'
require 'json'

module Manticoresearch
  class SearchApi
    def initialize(api_client = ApiClient.new)
      @api_client = api_client
    end

    # Executes a percolate query.
    # @param index [String] The index name.
    # @param percolate_request [Hash] The percolate request parameters.
    # @return [JSON] The response from the API.
    def percolate(index, percolate_request)
      percolate_with_http_info(index, percolate_request)
    end

    # Executes a search query.
    # @param search_request [Hash] The search request parameters.
    # @return [JSON] The response from the API.
    def search(search_request)
      search_with_http_info(search_request)
    end

    private

    # Executes a percolate query with HTTP info.
    # It only run on the percolate index.
    # @param index [String] The index name.
    # @param percolate_request [Hash] The percolate request parameters.
    # @return [Hash] The response from the API.
    def percolate_with_http_info(index, percolate_request)
      validate_percolate_params(index, percolate_request)
      path_params = { 'index' => index }
      header_params = set_header_params
      json_percolate_request = percolate_request.to_json

      @api_client.call_api(
        "/pq/#{index}/search",
        'POST',
        path_params: path_params,
        header_params: header_params,
        body: json_percolate_request
      )
    end

    def validate_percolate_params(index, percolate_request)
      raise ApiValueError, 'Missing the required parameter `index` when calling `percolate`' unless index

      return if percolate_request

      raise ApiValueError,
            'Missing the required parameter `percolate_request` when calling `percolate`'
    end

    def set_header_params
      header_params = {}
      header_accept = @api_client.select_header_accept(['application/json']) || 'application/json'
      header_params['Accept'] = header_accept
      header_content_type = @api_client.select_header_content_type(['application/json']) || 'application/json'
      header_params['Content-Type'] = header_content_type
      header_params
    end

    # Executes a search query with HTTP info.
    # @param search_request [Hash] The search request parameters.
    # @return [Hash] The response from the API.
    def search_with_http_info(search_request)
      validate_search_params(search_request)
      query_params = {}
      header_params = set_header_params
      json_search_request = search_request.to_json

      @api_client.call_api(
        '/search',
        'POST',
        query_params: query_params,
        header_params: header_params,
        body: json_search_request
      )
    end

    def validate_search_params(search_request)
      return unless search_request.nil? || search_request.empty?

      raise ApiValueError, 'Missing the required parameter `search_request` when calling `search`'
    end
  end
end

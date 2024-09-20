require_relative '../api_client'
require_relative '../exceptions'
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
    # @param async_req [Boolean, nil] Whether to execute the request asynchronously.
    # @return [JSON] The response from the API.
    def percolate(index, percolate_request, async_req = nil)
      percolate_with_http_info(index, percolate_request, async_req: async_req)
    end

    # Executes a percolate query with HTTP info.
    # @param index [String] The index name.
    # @param percolate_request [Hash] The percolate request parameters.
    # @param async_req [Boolean, nil] Whether to execute the request asynchronously.
    # @return [JSON] The response from the API.
    def percolate_with_http_info(index, percolate_request, async_req: nil)
      # Ensure the required parameters are provided
      raise ApiValueError.new('Missing the required parameter `index` when calling `percolate`') unless index
      raise ApiValueError.new('Missing the required parameter `percolate_request` when calling `percolate`') unless percolate_request

      # Set path and query parameters
      path_params = { 'index' => index }
      query_params = {}

      # Set header parameters
      header_params = {}
      header_accept = @api_client.select_header_accept(['application/json']) || 'application/json'
      header_params['Accept'] = header_accept

      header_content_type = @api_client.select_header_content_type(['application/json']) || 'application/json'
      header_params['Content-Type'] = header_content_type

      # Convert percolate_request to JSON
      json_percolate_request = percolate_request.to_json

      # Call the API
      response = @api_client.call_api(
        "/pq/#{index}/search",
        'POST',
        query_params: query_params,
        header_params: header_params,
        body: json_percolate_request
      )

      return response
    end

    # Executes a search query.
    # @param search_request [Hash] The search request parameters.
    # @param async_req [Boolean, nil] Whether to execute the request asynchronously.
    # @return [JSON] The response from the API.
    def search(search_request, async_req = nil)
      search_with_http_info(search_request, async_req: async_req)
    end

    # Executes a search query with HTTP info.
    # @param search_request [Hash] The search request parameters.
    # @param async_req [Boolean, nil] Whether to execute the request asynchronously.
    # @return [JSON] The response from the API.
    def search_with_http_info(search_request, async_req: nil)
      # Ensure the required parameter 'search_request' is provided
      raise ApiValueError.new('Missing the required parameter `search_request` when calling `search`') unless search_request

      # Set path and query parameters
      path_params = {}
      query_params = {}

      # Set header parameters
      header_params = {}
      header_accept = @api_client.select_header_accept(['application/json']) || 'application/json'
      header_params['Accept'] = header_accept

      header_content_type = @api_client.select_header_content_type(['application/json']) || 'application/json'
      header_params['Content-Type'] = header_content_type

      # Convert search_request to JSON
      json_search_request = search_request.to_json

      # Call the API
      response = @api_client.call_api(
        '/search',
        'POST',
        query_params: query_params,
        header_params: header_params,
        body: json_search_request
      )

      return response
    end
  end
end

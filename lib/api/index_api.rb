require_relative '../api_client'
require_relative '../exceptions'
require 'json'

module Manticoresearch
  # IndexApi - API
  class IndexApi
    def initialize(api_client = ApiClient.new)
      @api_client = api_client
    end

    # Performs a bulk operation.
    # @param body [Hash] The bulk request body.
    # @param async_req [Boolean, nil] Whether to execute the request asynchronously.
    # @return [JSON] The response from the API.
    def bulk(body, async_req = nil)
      bulk_with_http_info(body, async_req: async_req)
    end

    # Performs a bulk operation with HTTP info.
    # @param body [Hash] The bulk request body.
    # @param async_req [Boolean, nil] Whether to execute the request asynchronously.
    # @return [JSON] The response from the API.
    def bulk_with_http_info(body, async_req: nil)
      # Ensure the 'body' parameter is provided
      raise ApiValueError.new('Missing the required parameter `body` when calling `bulk`') unless body

      # Set header parameters
      header_params = {}
      header_accept = @api_client.select_header_accept(['application/json']) || 'application/json'
      header_params['Accept'] = header_accept

      header_content_type = @api_client.select_header_content_type(['application/json']) || 'application/json'
      header_params['Content-Type'] = header_content_type

      # Convert body to JSON
      json_body = body.to_json

      # Call the API
      response = @api_client.call_api(
        '/bulk',
        'POST',
        header_params: header_params,
        body: json_body
      )

      return response
    end

    # Deletes a document.
    # @param delete_document_request [Hash] The delete request parameters.
    # @param async_req [Boolean, nil] Whether to execute the request asynchronously.
    # @return [JSON] The response from the API.
    def delete(delete_document_request, async_req = nil)
      delete_with_http_info(delete_document_request, async_req: async_req)
    end

    # Deletes a document with HTTP info.
    # @param delete_document_request [Hash] The delete request parameters.
    # @param async_req [Boolean, nil] Whether to execute the request asynchronously.
    # @return [JSON] The response from the API.
    def delete_with_http_info(delete_document_request, async_req: nil)
      # Ensure the required parameter is provided
      raise ApiValueError.new('Missing the required parameter `delete_document_request` when calling `delete`') unless delete_document_request

      # Set header parameters
      header_params = {}
      header_accept = @api_client.select_header_accept(['application/json']) || 'application/json'
      header_params['Accept'] = header_accept

      header_content_type = @api_client.select_header_content_type(['application/json']) || 'application/json'
      header_params['Content-Type'] = header_content_type

      # Convert request to JSON
      json_delete_document_request = delete_document_request.to_json

      # Call the API
      response = @api_client.call_api(
        '/delete',
        'POST',
        header_params: header_params,
        body: json_delete_document_request
      )

      return response
    end

    # Inserts a document.
    # @param insert_document_request [Hash] The insert request parameters.
    # @param async_req [Boolean, nil] Whether to execute the request asynchronously.
    # @return [JSON] The response from the API.
    def insert(insert_document_request, async_req = nil)
      insert_with_http_info(insert_document_request, async_req: async_req)
    end

    # Inserts a document with HTTP info.
    # @param insert_document_request [Hash] The insert request parameters.
    # @param async_req [Boolean, nil] Whether to execute the request asynchronously.
    # @return [JSON] The response from the API.
    def insert_with_http_info(insert_document_request, async_req: nil)
      # Ensure the required parameter is provided
      raise ApiValueError.new('Missing the required parameter `insert_document_request` when calling `insert`') unless insert_document_request

      # Set header parameters
      header_params = {}
      header_accept = @api_client.select_header_accept(['application/json']) || 'application/json'
      header_params['Accept'] = header_accept

      header_content_type = @api_client.select_header_content_type(['application/json']) || 'application/json'
      header_params['Content-Type'] = header_content_type

      # Convert request to JSON
      json_insert_document_request = insert_document_request.to_json

      # Call the API
      response = @api_client.call_api(
        '/insert',
        'POST',
        header_params: header_params,
        body: json_insert_document_request
      )

      return response
    end

    # Replaces a document.
    # @param insert_document_request [Hash] The replace request parameters.
    # @param async_req [Boolean, nil] Whether to execute the request asynchronously.
    # @return [JSON] The response from the API.
    def replace(insert_document_request, async_req = nil)
      replace_with_http_info(insert_document_request, async_req: async_req)
    end

    # Replaces a document with HTTP info.
    # @param insert_document_request [Hash] The replace request parameters.
    # @param async_req [Boolean, nil] Whether to execute the request asynchronously.
    # @return [JSON] The response from the API.
    def replace_with_http_info(insert_document_request, async_req: nil)
      # Ensure the required parameter is provided
      raise ApiValueError.new('Missing the required parameter `insert_document_request` when calling `replace`') unless insert_document_request

      # Set header parameters
      header_params = {}
      header_accept = @api_client.select_header_accept(['application/json']) || 'application/json'
      header_params['Accept'] = header_accept

      header_content_type = @api_client.select_header_content_type(['application/json']) || 'application/json'
      header_params['Content-Type'] = header_content_type

      # Convert request to JSON
      json_insert_document_request = insert_document_request.to_json

      # Call the API
      response = @api_client.call_api(
        '/replace',
        'POST',
        header_params: header_params,
        body: json_insert_document_request
      )

      return response
    end

    # Updates a document.
    # @param update_document_request [Hash] The update request parameters.
    # @param async_req [Boolean, nil] Whether to execute the request asynchronously.
    # @return [JSON] The response from the API.
    def update(update_document_request, async_req = nil)
      update_with_http_info(update_document_request, async_req: async_req)
    end

    # Updates a document with HTTP info.
    # @param update_document_request [Hash] The update request parameters.
    # @param async_req [Boolean, nil] Whether to execute the request asynchronously.
    # @return [JSON] The response from the API.
    def update_with_http_info(update_document_request, async_req: nil)
      # Ensure the required parameter is provided
      raise ApiValueError.new('Missing the required parameter `update_document_request` when calling `update`') unless update_document_request

      # Set header parameters
      header_params = {}
      header_accept = @api_client.select_header_accept(['application/json']) || 'application/json'
      header_params['Accept'] = header_accept

      header_content_type = @api_client.select_header_content_type(['application/json']) || 'application/json'
      header_params['Content-Type'] = header_content_type

      # Convert request to JSON
      json_update_document_request = update_document_request.to_json

      # Call the API
      response = @api_client.call_api(
        '/update',
        'POST',
        header_params: header_params,
        body: json_update_document_request
      )

      return response
    end

    # Partially updates a document.
    # @param index [String] The index name.
    # @param id [Float] The document ID.
    # @param replace_document_request [Hash] The partial update request parameters.
    # @param async_req [Boolean, nil] Whether to execute the request asynchronously.
    # @return [JSON] The response from the API.
    def update_partial(index, id, replace_document_request, async_req = nil)
      update_partial_with_http_info(index, id, replace_document_request, async_req: async_req)
    end

    # Partially updates a document with HTTP info.
    # @param index [String] The index name.
    # @param id [Float] The document ID.
    # @param replace_document_request [Hash] The partial update request parameters.
    # @param async_req [Boolean, nil] Whether to execute the request asynchronously.
    # @return [JSON] The response from the API.
    def update_partial_with_http_info(index, id, replace_document_request, async_req: nil)
      # Ensure the required parameters are provided
      raise ApiValueError.new('Missing the required parameter `index` when calling `update_partial`') unless index
      raise ApiValueError.new('Missing the required parameter `id` when calling `update_partial`') unless id
      raise ApiValueError.new('Missing the required parameter `replace_document_request` when calling `update_partial`') unless replace_document_request

      # Set header parameters
      header_params = {}
      header_accept = @api_client.select_header_accept(['application/json']) || 'application/json'
      header_params['Accept'] = header_accept

      header_content_type = @api_client.select_header_content_type(['application/json']) || 'application/json'
      header_params['Content-Type'] = header_content_type

      # Convert request to JSON
      json_replace_document_request = replace_document_request.to_json

      # Call the API
      response = @api_client.call_api(
        "/#{index}/_update/#{id}",
        'POST',
        header_params: header_params,
        body: json_replace_document_request
      )

      return response
    end
  end
end

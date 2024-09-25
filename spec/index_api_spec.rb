# frozen_string_literal: true

# spec/manticoresearch/index_api_spec.rb

require 'rspec'
require 'json'
require_relative '../lib/api/index_api'
require_relative '../lib/api_client'

RSpec.describe Manticoresearch::IndexApi do
  let(:api_client) { instance_double(Manticoresearch::ApiClient) }
  let(:index_api) { described_class.new(api_client) }
  let(:response) { { 'result' => 'success' }.to_json }

  before do
    allow(api_client).to receive(:select_header_accept).with(['application/json']).and_return('application/json')
    allow(api_client).to receive(:select_header_content_type).with(['application/json']).and_return('application/json')
  end

  describe '#bulk' do
    it 'calls the API client with the correct parameters' do
      body = { 'actions' => [{ 'index' => { '_index' => 'test', '_id' => '1', 'data' => 'test data' } }] }

      expect(api_client).to receive(:call_api).with(
        '/bulk',
        'POST',
        header_params: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        },
        body: body.to_json
      ).and_return(response)

      result = index_api.bulk(body)
      expect(result).to eq(response)
    end

    it 'raises an error if body is missing' do
      expect do
        index_api.bulk(nil)
      end.to raise_error(Manticoresearch::ApiValueError,
                         'Missing the required parameter `body` when calling `bulk`')
    end
  end

  describe '#delete' do
    it 'calls the API client with the correct parameters' do
      delete_request = { 'index' => 'test', 'id' => '1' }

      expect(api_client).to receive(:call_api).with(
        '/delete',
        'POST',
        header_params: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        },
        body: delete_request.to_json
      ).and_return(response)

      result = index_api.delete(delete_request)
      expect(result).to eq(response)
    end

    it 'raises an error if delete_document_request is missing' do
      expect do
        index_api.delete(nil)
      end.to raise_error(Manticoresearch::ApiValueError,
                         'Missing the required parameter `delete_document_request` when calling `delete`')
    end
  end

  describe '#insert' do
    it 'calls the API client with the correct parameters' do
      insert_request = { 'index' => 'test', 'data' => 'new data' }

      expect(api_client).to receive(:call_api).with(
        '/insert',
        'POST',
        header_params: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        },
        body: insert_request.to_json
      ).and_return(response)

      result = index_api.insert(insert_request)
      expect(result).to eq(response)
    end

    it 'raises an error if insert_document_request is missing' do
      expect do
        index_api.insert(nil)
      end.to raise_error(Manticoresearch::ApiValueError,
                         'Missing the required parameter `insert_document_request` when calling `insert`')
    end
  end

  describe '#replace' do
    it 'calls the API client with the correct parameters' do
      replace_request = { 'index' => 'test', 'id' => '1', 'data' => 'updated data' }

      expect(api_client).to receive(:call_api).with(
        '/replace',
        'POST',
        header_params: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        },
        body: replace_request.to_json
      ).and_return(response)

      result = index_api.replace(replace_request)
      expect(result).to eq(response)
    end

    it 'raises an error if insert_document_request is missing' do
      expect do
        index_api.replace(nil)
      end.to raise_error(Manticoresearch::ApiValueError,
                         'Missing the required parameter `insert_document_request` when calling `replace`')
    end
  end

  describe '#update' do
    it 'calls the API client with the correct parameters' do
      update_request = { 'index' => 'test', 'id' => '1', 'data' => 'modified data' }

      expect(api_client).to receive(:call_api).with(
        '/update',
        'POST',
        header_params: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        },
        body: update_request.to_json
      ).and_return(response)

      result = index_api.update(update_request)
      expect(result).to eq(response)
    end

    it 'raises an error if update_document_request is missing' do
      expect do
        index_api.update(nil)
      end.to raise_error(Manticoresearch::ApiValueError,
                         'Missing the required parameter `update_document_request` when calling `update`')
    end
  end

  describe '#update_partial' do
    it 'calls the API client with the correct parameters' do
      index = 'test'
      id = 1
      partial_update_request = { 'data' => 'partial update' }

      expect(api_client).to receive(:call_api).with(
        "/#{index}/_update/#{id}",
        'POST',
        header_params: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        },
        body: partial_update_request.to_json
      ).and_return(response)

      result = index_api.update_partial(index, id, partial_update_request)
      expect(result).to eq(response)
    end

    it 'raises an error if parameters are missing' do
      expect do
        index_api.update_partial(nil, 1,
                                 {})
      end.to raise_error(Manticoresearch::ApiValueError,
                         'Missing the required parameter `index` when calling `update_partial`')
      expect do
        index_api.update_partial('test', nil,
                                 {})
      end.to raise_error(Manticoresearch::ApiValueError,
                         'Missing the required parameter `id` when calling `update_partial`')
      expect do
        index_api.update_partial('test', 1,
                                 nil)
      end.to raise_error(Manticoresearch::ApiValueError,
                         'Missing the required parameter `replace_document_request` when calling `update_partial`')
    end
  end
end

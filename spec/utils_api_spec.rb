# frozen_string_literal: true

# spec/utils_api_spec.rb

require 'spec_helper'
require_relative '../lib/api/utils_api'
require_relative '../lib/api_client'

RSpec.describe Manticoresearch::UtilsApi do
  let(:api_client) { instance_double(Manticoresearch::ApiClient) }
  let(:utils_api) { described_class.new(api_client) }
  let(:body) { 'SELECT * FROM index' }

  describe '#sql' do
    it 'calls sql_with_http_info with the correct parameters' do
      expect(utils_api).to receive(:sql_with_http_info).with(body, raw_response: nil)
      utils_api.sql(body)
    end
  end

  describe '#sql_with_http_info' do
    let(:response) { { 'hits' => [] } }
    let(:encoded_body) { 'query=SELECT%20*%20FROM%20index' }

    before do
      allow(api_client).to receive_messages(select_header_accept: 'application/json',
                                            select_header_content_type: 'text/plain', call_api: response)
    end

    context 'when body is missing' do
      it 'raises an ApiValueError' do
        expect do
          utils_api.sql_with_http_info(nil)
        end.to raise_error(Manticoresearch::ApiValueError,
                           'Missing the required parameter `body` when calling `sql`')
      end
    end

    context 'when raw_response is nil' do
      it 'makes the correct API call and returns the response' do
        expect(api_client).to receive(:call_api).with(
          '/sql',
          'POST',
          query_params: {},
          header_params: { 'Accept' => 'application/json', 'Content-Type' => 'text/plain' },
          body: 'mode=raw&query=SELECT+*+FROM+index'
        ).and_return(response)

        result = utils_api.sql_with_http_info(body)
        expect(result).to eq(response)
      end
    end

    context 'when raw_response is true' do
      it 'makes the correct API call and returns the response' do
        expect(api_client).to receive(:call_api).with(
          '/sql',
          'POST',
          query_params: { 'raw_response' => 'true' },
          header_params: { 'Accept' => 'application/json', 'Content-Type' => 'text/plain' },
          body: 'mode=raw&query=SELECT+*+FROM+index'
        ).and_return(response)

        result = utils_api.sql_with_http_info(body, raw_response: true)
        expect(result).to eq(response)
      end
    end

    context 'when raw_response is false' do
      it 'makes the correct API call and returns an array with the response' do
        expect(api_client).to receive(:call_api).with(
          '/sql',
          'POST',
          query_params: { 'raw_response' => 'false' },
          header_params: { 'Accept' => 'application/json', 'Content-Type' => 'text/plain' },
          body: 'query=SELECT+*+FROM+index'
        ).and_return(response)

        result = utils_api.sql_with_http_info('SELECT * FROM index', raw_response: false)
        expect(result).to eq([response])
      end
    end

    context 'with different body content' do
      let(:body) { 'SHOW TABLES' }
      let(:encoded_body) { 'query=SHOW%20TABLES' }

      it 'encodes the body correctly and makes the API call' do
        expect(api_client).to receive(:call_api).with(
          '/sql',
          'POST',
          query_params: {},
          header_params: { 'Accept' => 'application/json', 'Content-Type' => 'text/plain' },
          body: 'mode=raw&query=SHOW+TABLES'
        ).and_return(response)

        result = utils_api.sql_with_http_info(body)
        expect(result).to eq(response)
      end
    end
  end
end

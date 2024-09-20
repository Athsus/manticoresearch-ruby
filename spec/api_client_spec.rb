# spec/api_client_spec.rb
require 'spec_helper'
require 'json'
require_relative '../lib/api_client'
require_relative '../lib/configuration'
require_relative '../lib/rest'
require_relative '../lib/exceptions/api_exception'

RSpec.describe Manticoresearch::ApiClient do
  let(:configuration) { Manticoresearch::Configuration.new }
  let(:api_client) { described_class.new(configuration) }

  describe '#initialize' do
    context 'when initialized with default configuration' do
      it 'sets the default headers' do
        expect(api_client.default_headers['User-Agent']).to eq('manticoresearch/ruby')
      end

      it 'does not set any additional headers' do
        expect(api_client.default_headers.keys.size).to eq(1)
      end
    end

    context 'when initialized with custom headers' do
      let(:options) { { header_name: 'Custom-Header', header_value: 'CustomValue' } }
      let(:api_client) { described_class.new(configuration, options) }

      it 'includes the custom header in default headers' do
        expect(api_client.default_headers['Custom-Header']).to eq('CustomValue')
      end
    end

    context 'when initialized with cookie' do
      let(:options) { { cookie: 'sessionid=abc123' } }
      let(:api_client) { described_class.new(configuration, options) }

      it 'sets the cookie' do
        expect(api_client.cookie).to eq('sessionid=abc123')
      end
    end
  end

  describe '#call_api' do
    let(:resource_path) { '/test' }
    let(:method) { :get }
    let(:options) do
      {
        header_params: { 'Accept' => 'application/json' },
        path_params: { 'id' => 1 },
        query_params: { 'search' => 'test' },
        body: { key: 'value' }.to_json,
        response_type: 'Hash<String, Object>'
      }
    end
    let(:full_url) { 'http://localhost:9308/test' }

    before do
      allow(api_client).to receive(:build_full_url).and_return(full_url)
      allow(api_client).to receive(:prepare_headers).and_return(api_client.default_headers)
      allow(api_client).to receive(:deserialize).and_return({ 'result' => 'success' })
      @rest_client_double = instance_double(Manticoresearch::Rest)
      allow(@rest_client_double).to receive(:request).and_return(double(data: '{"result":"success"}'))
      api_client.instance_variable_set(:@rest, @rest_client_double)
    end

    it 'builds the full URL' do
      api_client.call_api(resource_path, method, options)
      expect(api_client).to have_received(:build_full_url).with(resource_path, options[:path_params])
    end

    it 'prepares the headers' do
      api_client.call_api(resource_path, method, options)
      expect(api_client).to have_received(:prepare_headers).with(options[:header_params])
    end

    it 'makes a request using Rest client' do
      api_client.call_api(resource_path, method, options)
      expect(@rest_client_double).to have_received(:request).with(method, full_url, options[:query_params], api_client.default_headers, options[:body])
    end

    it 'deserializes the response data' do
      api_client.call_api(resource_path, method, options)
      expect(api_client).to have_received(:deserialize).with('{"result":"success"}', options[:response_type])
    end

    it 'returns the deserialized data' do
      result = api_client.call_api(resource_path, method, options)
      expect(result).to eq({ 'result' => 'success' })
    end
  end

  describe '#prepare_headers' do
    context 'when header_params are provided' do
      let(:header_params) { { 'Authorization' => 'Bearer token' } }

      it 'merges default headers with header_params' do
        headers = api_client.send(:prepare_headers, header_params)
        expect(headers['User-Agent']).to eq('manticoresearch/ruby')
        expect(headers['Authorization']).to eq('Bearer token')
      end
    end

    context 'when header_params are nil' do
      it 'returns default headers' do
        headers = api_client.send(:prepare_headers, nil)
        expect(headers).to eq(api_client.default_headers)
      end
    end
  end

  describe '#build_full_url' do
    let(:resource_path) { '/{index}/documents' }
    let(:path_params) { { 'index' => 'test_index' } }

    it 'replaces path parameters in the resource path' do
      full_url = api_client.send(:build_full_url, resource_path, path_params)
      expect(full_url).to eq("#{configuration.host}/test_index/documents")
    end

    it 'encodes path parameters' do
      path_params = { 'index' => 'test index' }
      full_url = api_client.send(:build_full_url, resource_path, path_params)
      expect(full_url).to eq("#{configuration.host}/test%20index/documents")
    end

    context 'when path_params are nil' do
      it 'returns the resource path appended to the host' do
        full_url = api_client.send(:build_full_url, resource_path, nil)
        expect(full_url).to eq("#{configuration.host}/#{resource_path}")
      end
    end
  end

  describe '#deserialize' do
    context 'when response data is valid JSON' do
      let(:data) { '{"key":"value"}' }

      it 'parses the JSON data' do
        result = api_client.send(:deserialize, data)
        expect(result).to eq({ 'key' => 'value' })
      end
    end

    context 'when response data is invalid JSON' do
      let(:data) { 'invalid json' }

      it 'raises a JSON::ParserError' do
        expect { api_client.send(:deserialize, data) }.to raise_error(JSON::ParserError)
      end
    end
  end

  describe 'HTTP methods' do
    let(:url) { '/test' }
    let(:headers) { { 'Content-Type' => 'application/json' } }
    let(:body) { { key: 'value' }.to_json }
    let(:response_data) { { 'result' => 'success' } }

    before do
      allow(api_client).to receive(:call_api).and_return(response_data)
    end

    describe '#get_resp' do
      it 'calls #call_api with GET method' do
        result = api_client.send(:get_resp, url, headers, nil)
        expect(api_client).to have_received(:call_api).with(url, 'GET', nil, nil, headers)
        expect(result).to eq(response_data)
      end
    end

    describe '#post_resp' do
      it 'calls #call_api with POST method' do
        result = api_client.send(:post_resp, url, headers, body)
        expect(api_client).to have_received(:call_api).with(url, 'POST', nil, nil, headers, body)
        expect(result).to eq(response_data)
      end
    end

    describe '#put_resp' do
      it 'calls #call_api with PUT method' do
        result = api_client.send(:put_resp, url, headers, body)
        expect(api_client).to have_received(:call_api).with(url, 'PUT', nil, nil, headers, body)
        expect(result).to eq(response_data)
      end
    end

    describe '#delete_resp' do
      it 'calls #call_api with DELETE method' do
        result = api_client.send(:delete_resp, url, headers, body)
        expect(api_client).to have_received(:call_api).with(url, 'DELETE', nil, nil, headers, body)
        expect(result).to eq(response_data)
      end
    end
  end

  describe '#select_header_accept' do
    context 'when accepts array is empty' do
      it 'returns nil' do
        result = api_client.send(:select_header_accept, [])
        expect(result).to be_nil
      end
    end

    context 'when accepts array contains application/json' do
      it 'returns application/json' do
        result = api_client.send(:select_header_accept, ['application/xml', 'application/json'])
        expect(result).to eq('application/json')
      end
    end

    context 'when accepts array does not contain application/json' do
      it 'returns the first accept header' do
        result = api_client.send(:select_header_accept, ['application/xml', 'text/plain'])
        expect(result).to eq('application/xml')
      end
    end
  end

  describe '#select_header_content_type' do
    context 'when content_types array is empty' do
      it 'returns application/json' do
        result = api_client.send(:select_header_content_type, [])
        expect(result).to eq('application/json')
      end
    end

    context 'when content_types array contains application/json' do
      it 'returns application/json' do
        result = api_client.send(:select_header_content_type, ['application/xml', 'application/json'])
        expect(result).to eq('application/json')
      end
    end

    context 'when content_types array does not contain application/json' do
      it 'returns the first content type' do
        result = api_client.send(:select_header_content_type, ['application/xml', 'text/plain'])
        expect(result).to eq('application/xml')
      end
    end
  end

  describe '#sanitize_for_serialization' do
    it 'sanitizes an array of objects' do
      array = ['string', 123, Time.now]
      result = api_client.send(:sanitize_for_serialization, array)
      expect(result[0]).to eq('string')
      expect(result[1]).to eq(123)
      expect(result[2]).to be_a(String)
    end

    it 'sanitizes a hash of objects' do
      hash = { key1: 'value', key2: Time.now }
      result = api_client.send(:sanitize_for_serialization, hash)
      expect(result[:key1]).to eq('value')
      expect(result[:key2]).to be_a(String)
    end

    it 'returns primitive types as is' do
      expect(api_client.send(:sanitize_for_serialization, 'string')).to eq('string')
      expect(api_client.send(:sanitize_for_serialization, 123)).to eq(123)
    end
  end

  describe '#parameters_to_tuples' do
    it 'converts hash parameters to array of tuples' do
      params = { 'key1' => 'value1', 'key2' => 'value2' }
      result = api_client.send(:parameters_to_tuples, params)
      expect(result).to eq([['key1', 'value1'], ['key2', 'value2']])
    end
  end

  describe '#files_parameters' do
    context 'when files are provided' do
      it 'returns array of file parameters' do
        files = { 'file1' => '/path/to/file1', 'file2' => '/path/to/file2' }
        result = api_client.send(:files_parameters, files)
        expect(result).to eq([['file1', '/path/to/file1'], ['file2', '/path/to/file2']])
      end
    end

    context 'when files are nil' do
      it 'returns empty array' do
        result = api_client.send(:files_parameters, nil)
        expect(result).to eq([])
      end
    end
  end

  describe '#update_params_for_auth' do
    it 'does not raise an error when called' do
      expect {
        api_client.send(:update_params_for_auth, {}, {}, [], nil)
      }.not_to raise_error
    end

    it 'is expected to be implemented as needed' do
      # Since the method is a placeholder, we can only test that it exists
      expect(api_client.private_methods).to include(:update_params_for_auth)
    end
  end

  describe '#close' do
    it 'responds to #close' do
      expect(api_client).to respond_to(:close)
    end

    it 'does not raise an error when called' do
      expect { api_client.close }.not_to raise_error
    end
  end
end

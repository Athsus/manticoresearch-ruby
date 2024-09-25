# frozen_string_literal: true

# spec/api_client_spec.rb
require 'spec_helper'
require 'json'
require 'webmock/rspec'
require 'httparty'

require_relative '../lib/api_client'
require_relative '../lib/configuration'
require_relative '../lib/rest'
require_relative '../lib/exceptions/api_exception'

RSpec.describe Manticoresearch::ApiClient do
  # 定义默认和自定义配置
  let(:default_configuration) { Manticoresearch::Configuration.default }
  let(:custom_configuration) { Manticoresearch::Configuration.new(host: 'http://127.0.0.1:9308') }

  # 创建 ApiClient 实例
  let(:api_client_default) { described_class.new }
  let(:api_client_custom) do
    described_class.new(custom_configuration, header_name: 'X-Custom-Header', header_value: 'CustomValue')
  end

  # 创建 RESTClientObject 的模拟对象
  let(:rest_client_double) { instance_double(Manticoresearch::RESTClientObject) }

  before do
    # 允许 ApiClient 初始化 RESTClientObject 时返回模拟对象
    allow(Manticoresearch::RESTClientObject).to receive(:new).and_return(rest_client_double)
  end

  describe '#initialize' do
    context 'with default configuration' do
      it 'sets default headers correctly' do
        expect(api_client_default.default_headers).to eq({ 'User-Agent' => 'manticoresearch/ruby' })
      end

      it 'does not set additional headers if none provided' do
        expect(api_client_default.default_headers).not_to have_key('X-Custom-Header')
      end
    end

    context 'with custom configuration and headers' do
      it 'sets default and custom headers correctly' do
        expect(api_client_custom.default_headers).to eq({ 'User-Agent' => 'manticoresearch/ruby',
                                                          'X-Custom-Header' => 'CustomValue' })
      end
    end
  end

  describe '#call_api' do
    let(:resource_path) { '/test_endpoint' }
    let(:method) { 'GET' }
    let(:options) do
      {
        path_params: { id: 1 },
        query_params: { search: 'test' },
        header_params: { 'Authorization' => 'Bearer token' },
        body: { key: 'value' },
        response_type: 'json'
      }
    end

    let(:full_url) { 'http://127.0.0.1:9308/test_endpoint' }

    let(:rest_response) do
      instance_double(Manticoresearch::RESTResponse,
                      status: 200,
                      data: '{"success": true}',
                      headers: { 'Content-Type' => 'application/json' })
    end

    before do
      # 允许 RESTClientObject 接收到请求并返回成功响应
      allow(rest_client_double).to receive(:request).with(
        method,
        full_url,
        query_params: options[:query_params],
        headers: options[:header_params],
        body: options[:body]
      ).and_return(rest_response)
    end

    it 'calls RESTClientObject with correct parameters and returns deserialized data' do
      expect(rest_client_double).to receive(:request).with(
        method,
        full_url,
        query_params: options[:query_params],
        headers: options[:header_params].merge({ 'User-Agent' => 'manticoresearch/ruby' }),
        body: options[:body]
      ).and_return(rest_response)

      result = api_client_default.call_api(resource_path, method, options)

      expect(result).to eq(rest_response.data)
    end

    context 'when the API call fails with an error' do
      let(:error_rest_response) do
        instance_double(Manticoresearch::RESTResponse,
                        status: 500,
                        data: '{"error":"unknown local table(s) \'hn_small\' in search request"}',
                        headers: { 'Content-Type' => 'application/json' })
      end

      before do
        allow(rest_client_double).to receive(:request).with(
          method,
          full_url,
          query_params: options[:query_params],
          headers: options[:header_params].merge({ 'User-Agent' => 'manticoresearch/ruby' }),
          body: options[:body]
        ).and_return(error_rest_response)
      end

      it 'raises ApiException with specific error message' do
        expect do
          api_client_default.call_api(resource_path, method, options)
        end.to raise_error(Manticoresearch::ApiException,
                           "unknown local table(s) 'hn_small' in search request")
      end
    end
  end

  describe '#select_header_accept' do
    it 'returns application/json if available' do
      accepts = ['application/json', 'text/plain']
      expect(api_client_default.select_header_accept(accepts)).to eq('application/json')
    end

    it 'returns first accept type if application/json not available' do
      accepts = ['text/plain', 'application/xml']
      expect(api_client_default.select_header_accept(accepts)).to eq('text/plain')
    end

    it 'returns nil if accepts array is empty' do
      accepts = []
      expect(api_client_default.select_header_accept(accepts)).to be_nil
    end
  end

  describe '#select_header_content_type' do
    it 'returns application/json if available' do
      content_types = ['application/json', 'text/plain']
      expect(api_client_default.select_header_content_type(content_types)).to eq('application/json')
    end

    it 'returns first content type if application/json not available' do
      content_types = ['text/plain', 'application/xml']
      expect(api_client_default.select_header_content_type(content_types)).to eq('text/plain')
    end

    it 'returns application/json if content types array is empty' do
      content_types = []
      expect(api_client_default.select_header_content_type(content_types)).to eq('application/json')
    end
  end
end

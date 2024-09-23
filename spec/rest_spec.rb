# frozen_string_literal: true

require 'rspec'
require 'httparty'
require 'webmock/rspec'
require 'json'

require_relative '../lib/configuration'
require_relative '../lib/rest'

# Disable external HTTP requests to ensure tests are self-contained
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.describe Manticoresearch::RESTResponse do
  describe '#initialize' do
    subject { described_class.new(mock_response) }

    let(:mock_response) do
      instance_double(
        HTTParty::Response,
        code: 200,
        body: '{"success":true}',
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    it 'assigns the status code correctly' do
      expect(subject.status).to eq(200)
    end

    it 'assigns the data correctly' do
      expect(subject.data).to eq('{"success":true}')
    end

    it 'assigns the headers correctly' do
      expect(subject.headers).to eq({ 'Content-Type' => 'application/json' })
    end
  end

  describe '#getheaders' do
    subject { described_class.new(mock_response) }

    let(:headers) { { 'Content-Type' => 'application/json', 'X-Custom-Header' => 'CustomValue' } }
    let(:mock_response) do
      instance_double(
        HTTParty::Response,
        code: 200,
        body: '{"success":true}',
        headers: headers
      )
    end

    it 'returns all headers' do
      expect(subject.getheaders).to eq(headers)
    end
  end

  describe '#getheader' do
    subject { described_class.new(mock_response) }

    let(:headers) { { 'Content-Type' => 'application/json', 'X-Custom-Header' => 'CustomValue' } }
    let(:mock_response) do
      instance_double(
        HTTParty::Response,
        code: 200,
        body: '{"success":true}',
        headers: headers
      )
    end

    context 'when the header exists' do
      it 'returns the header value' do
        expect(subject.getheader('Content-Type')).to eq('application/json')
        expect(subject.getheader('X-Custom-Header')).to eq('CustomValue')
      end
    end

    context 'when the header does not exist' do
      it 'returns the default value' do
        expect(subject.getheader('Non-Existent-Header')).to be_nil
        expect(subject.getheader('Non-Existent-Header', 'DefaultValue')).to eq('DefaultValue')
      end
    end
  end
end

RSpec.describe Manticoresearch::RESTClientObject do
  let(:configuration) { instance_double(Manticoresearch::Configuration, host: 'http://localhost:9308') }
  let(:rest_client) { described_class.new(configuration) }

  # Define the base URI and endpoints
  let(:base_uri) { 'http://localhost:9308' }
  let(:full_url) { "#{base_uri}/test_endpoint" }

  describe '#initialize' do
    it 'sets the correct base URI' do
      expect(rest_client.instance_variable_get(:@base_uri)).to eq('http://localhost:9308')
    end

    context 'when host is missing scheme' do
      let(:configuration) { instance_double(Manticoresearch::Configuration, host: 'localhost:9308') }
      let(:rest_client) { described_class.new(configuration) }

      it 'defaults to http scheme' do
        expect(rest_client.instance_variable_get(:@base_uri)).to eq('http://localhost:9308')
      end
    end

    context 'when host includes scheme and port' do
      let(:configuration) { instance_double(Manticoresearch::Configuration, host: 'https://api.example.com:8080') }
      let(:rest_client) { described_class.new(configuration) }

      it 'parses the correct base URI' do
        expect(rest_client.instance_variable_get(:@base_uri)).to eq('https://api.example.com:8080')
      end
    end
  end

  describe '#request' do
    subject { rest_client.request(method, url, query_params: query_params, headers: headers, body: body) }

    let(:method) { 'GET' }
    let(:url) { '/test_endpoint' }
    let(:query_params) { { search: 'query' } }
    let(:headers) { { 'Authorization' => 'Bearer token' } }
    let(:body) { { key: 'value' } }
    let(:response_body) { { success: true, data: 'Test Data' }.to_json }

    context 'when the request is successful' do
      before do
        stub_request(:get, "#{base_uri}/test_endpoint")
          .with(query: query_params, headers: headers)
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns a RESTResponse object with correct attributes' do
        rest_response = subject

        expect(rest_response).to be_a(Manticoresearch::RESTResponse)
        expect(rest_response.status).to eq(200)
        expect(rest_response.data).to eq(response_body)
        expect(rest_response.headers['content-type']).to include('application/json')
      end
    end

    context 'when the request includes a body' do
      let(:method) { 'POST' }
      let(:body) { { key: 'value' } }

      before do
        stub_request(:post, "#{base_uri}/test_endpoint")
          .with(
            query: query_params,
            headers: headers.merge('Content-Type' => 'application/json'),
            body: body.to_json
          )
          .to_return(status: 201, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'sends the correct body and headers' do
        rest_response = subject

        expect(rest_response.status).to eq(201)
        expect(rest_response.data).to eq(response_body)
        expect(rest_response.headers['content-type']).to include('application/json')
      end
    end

    context 'when the request fails with a server error' do
      before do
        stub_request(:get, "#{base_uri}/test_endpoint")
          .with(query: query_params, headers: headers)
          .to_return(
            status: 500,
            body: { error: "unknown local table(s) 'hn_small' in search request" }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'raises an ApiException' do
        expect { subject }.to raise_error(
          Manticoresearch::ApiException,
          "unknown local table(s) 'hn_small' in search request"
        )
      end
    end

    context 'when no query_params or headers are provided' do
      let(:query_params) { nil }
      let(:headers) { nil }
      let(:method) { 'GET' }

      before do
        stub_request(:get, "#{base_uri}/test_endpoint")
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'defaults headers to an empty hash and sends the request successfully' do
        rest_response = rest_client.request(method, url)

        expect(rest_response.status).to eq(200)
        expect(rest_response.data).to eq(response_body)
        expect(rest_response.headers['content-type']).to include('application/json')
      end
    end
  end
end

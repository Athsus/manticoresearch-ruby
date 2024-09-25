# frozen_string_literal: true

require 'rspec'
require 'httparty'
require 'json'
require 'spec_helper'

require_relative '../lib/api/search_api'

RSpec.describe Manticoresearch::SearchApi do
  # set the base url to the local manticoresearch instance
  BASE_URL = 'http://localhost:9308'
  INSERT_ENDPOINT = "#{BASE_URL}/insert"
  DELETE_ENDPOINT = "#{BASE_URL}/delete"

  # instantiate the search api
  let(:search_api) { described_class.new }

  # define the test documents
  let(:documents) do
    [
      {
        index: 'products_for_test',
        id: 0,
        doc: {
          title: 'Crossbody Bag with Tassel',
          price: 19.85
        }
      },
      {
        index: 'products_for_test',
        id: 0,
        doc: {
          title: 'Crossbody Bag with Tassel'
        }
      },
      {
        index: 'products_for_test',
        id: 0,
        doc: {
          title: 'Yellow bag'
        }
      }
    ]
  end

  # Helper method to insert a document
  def insert_document(document)
    response = HTTParty.post(
      INSERT_ENDPOINT,
      headers: { 'Content-Type' => 'application/json' },
      body: document.to_json
    )
    return if response.success?

    raise "Failed to insert document #{document[:id]}: #{response.body}"
  end

  # Helper method to delete documents
  def delete_documents(index, query)
    response = HTTParty.post(
      DELETE_ENDPOINT,
      headers: { 'Content-Type' => 'application/json' },
      body: {
        index: index,
        query: query
      }.to_json
    )
    return if response.success?

    raise "Failed to delete documents: #{response.body}"
  end

  # insert the test documents before each test
  before do
    documents.each do |doc|
      insert_document(doc)
    end
  end

  # delete the test documents after each test
  after do
    delete_documents('products_for_test', { match_all: {} })
  end

  describe '#search' do
    it 'returns documents matching the search query' do
      search_request = {
        index: 'products_for_test',
        query: {
          match_phrase: {
            title: 'Crossbody Bag with Tassel'
          }
        }
      }

      # execute the search
      response = search_api.search(search_request)

      # assert that the response contains two matching documents
      expect(response).to have_key('hits')
      expect(response['hits']).to have_key('hits')
      expect(response['hits']['hits'].size).to eq(2)

      # validate the content of each returned document
      response['hits']['hits'].each do |hit|
        expect(hit).to have_key('_source')
        expect(hit['_source']).to include('title' => 'Crossbody Bag with Tassel')
      end
    end

    it 'raises ApiValueError when search_request is missing' do
      expect do
        search_api.search(nil)
      end.to raise_error(Manticoresearch::ApiValueError,
                         'Missing the required parameter `search_request` when calling `search`')
    end

    it 'raises ApiValueError when search_request is empty' do
      expect do
        search_api.search({})
      end.to raise_error(Manticoresearch::ApiValueError,
                         'Missing the required parameter `search_request` when calling `search`')
    end
  end

  describe '#percolate' do
    # it 'executes a percolate query successfully' do
      
    # end

    it 'raises ApiValueError when index is missing' do
      percolate_request = {
        query: {
          match: {
            title: 'Crossbody Bag with Tassel'
          }
        }
      }

      expect do
        search_api.percolate(nil,
                             percolate_request)
      end.to raise_error(Manticoresearch::ApiValueError,
                         'Missing the required parameter `index` when calling `percolate`')
    end

    it 'raises ApiValueError when percolate_request is missing' do
      index = 'products_for_test'

      expect do
        search_api.percolate(index,
                             nil)
      end.to raise_error(Manticoresearch::ApiValueError,
                         'Missing the required parameter `percolate_request` when calling `percolate`')
    end

    it 'raises ApiValueError when percolate keyword is vacancy' do
      index = 'products_for_test'
      percolate_request = {
        query: {
          match: {
            title: 'Crossbody Bag with Tassel'
          }
        }
      }

      expect do
        search_api.percolate(index,
                             percolate_request)
      end.to raise_error(Manticoresearch::ApiException,
                         '"percolate" property missing')
    end
  end
end

# frozen_string_literal: true

require 'rspec'
require_relative '../lib/api/index_api'
require_relative '../lib/api/search_api'
require_relative '../lib/api/utils_api'
require_relative '../lib/api_client'

RSpec.describe 'Manticoresearch API Manual Tests' do
  let(:default_configuration) { Manticoresearch::Configuration.default }
  let(:api_client) { Manticoresearch::ApiClient.new(default_configuration) }
  let(:index_api) { Manticoresearch::IndexApi.new(api_client) }
  let(:search_api) { Manticoresearch::SearchApi.new(api_client) }
  let(:utils_api) { Manticoresearch::UtilsApi.new(api_client) }
  let(:test_index) { 'manual_test_index' }

  before do
    utils_api.sql("DROP TABLE IF EXISTS #{test_index}")
    utils_api.sql("CREATE TABLE #{test_index} (title TEXT, num INT)")
  end

  describe '#bulk' do
    it 'multiple bulk and delete' do
      batch_create_instruction = [
        {
          create: {
            index: test_index,
            id: 1,
            doc: {
              title: 'title 1',
              num: 111
            }
          }
        },
        {
          create: {
            index: test_index,
            id: 2,
            doc: {
              title: 'title 2',
              num: 222
            }
          }
        }
      ]

      result = index_api.bulk(batch_create_instruction)
      expect(result['items'][0]['bulk']['_index']).to eq(test_index)
      expect(result['items'][0]['bulk']['created']).to eq(2)

      response = search_api.search({ index: test_index, query: { match_all: {} } })

      expect(response['hits']['total']).to eq(2)
      first_doc = response['hits']['hits'][0]
      expect(first_doc['_source']['title']).to eq('title 1')
      expect(first_doc['_source']['num']).to eq(111)
      second_doc = response['hits']['hits'][1]
      expect(second_doc['_source']['title']).to eq('title 2')
      expect(second_doc['_source']['num']).to eq(222)

      # delete the first document by id
      delete_body = {
        index: test_index,
        id: 1
      }
      index_api.delete(delete_body)

      response = search_api.search({ index: test_index, query: { match_all: {} } })
      # check the number of documents
      expect(response['hits']['hits'].length).to eq(1)
      first_doc = response['hits']['hits'][0]
      expect(first_doc['_source']['title']).to eq('title 2')
      expect(first_doc['_source']['num']).to eq(222)

      batch_insert_instruction = [
        {
          insert: {
            index: test_index,
            id: 3,
            doc: {
              title: 'title 3',
              num: 333
            }
          }
        },
        {
          insert: {
            index: test_index,
            id: 4,
            doc: {
              title: 'title 4',
              num: 444
            }
          }
        }
      ]

      result = index_api.bulk(batch_insert_instruction)
      expect(result['items'][0]['bulk']['_index']).to eq(test_index)
      expect(result['items'][0]['bulk']['created']).to eq(2)

      response = search_api.search({ index: test_index, query: { match_all: {} } })
      expect(response['hits']['total']).to eq(3)

      batch_replace_instruction = [
        {
          replace: {
            index: test_index,
            id: 2,
            doc: {
              title: 'replaced',
              num: 0
            }
          }
        },
        {
          replace: {
            index: test_index,
            id: 3,
            doc: {
              title: 'replaced',
              num: 0
            }
          }
        }
      ]

      result = index_api.bulk(batch_replace_instruction)
      expect(result['items'][0]['bulk']['_index']).to eq(test_index)
      expect(result['items'][0]['bulk']['created']).to eq(2)

      response = search_api.search({ index: test_index, query: { term: {
                                     title: 'replaced'
                                   } } })

      expect(response['hits']['total']).to eq(2)
      (response['hits']['hits']).each do |doc|
        expect(doc['_source']['title']).to eq('replaced')
        expect(doc['_source']['num']).to eq(0)
      end

      batch_update_instruction = [
        {
          update: {
            index: test_index,
            doc: {
              num: 1_234_567
            }
          }
        }
      ]
      result = index_api.bulk(batch_update_instruction)
      expect(result['items'][0]['bulk']['_index']).to eq(test_index)
      expect(result['items'][0]['bulk']['updated']).to eq(3)

      response = search_api.search({ index: test_index, query: { match_all: {} } })
      expect(response['hits']['total']).to eq(3)
      (response['hits']['hits']).each do |doc|
        expect(doc['_source']['num']).to eq(1_234_567)
      end

      batch_delete_instruction = [
        {
          delete: {
            index: test_index,
            id: 2
          }
        },
        {
          delete: {
            index: test_index,
            id: 4
          }
        }
      ]

      result = index_api.bulk(batch_delete_instruction)
      expect(result['items'][0]['bulk']['_index']).to eq(test_index)
      expect(result['items'][0]['bulk']['deleted']).to eq(2)

      response = search_api.search({ index: test_index, query: { match_all: {} } })
      expect(response['hits']['total']).to eq(1)
      first_doc = response['hits']['hits'][0]
      expect(first_doc['_source']['title']).to eq('replaced')
      expect(first_doc['_source']['num']).to eq(1_234_567)
    end
  end

  describe '#sql' do
    it 'describe table' do
      response = utils_api.sql("DESCRIBE #{test_index}")
      fields = response[0]['data']
      expect(fields.length).to eq(3)
      id_field = fields.find { |f| f['Field'] == 'id' }
      expect(id_field['Type']).to eq('bigint')

      title_field = fields.find { |f| f['Field'] == 'title' }
      expect(title_field['Type']).to eq('text')
      expect(title_field['Properties']).to eq('indexed stored')

      num_field = fields.find { |f| f['Field'] == 'num' }
      expect(num_field['Type']).to eq('uint')
    end

    it 'query table' do
      index_api.insert({
                         index: test_index,
                         id: 1,
                         doc: {
                           title: 'title 1',
                           num: 111
                         }
                       })
      response = utils_api.sql("SELECT * FROM #{test_index}", false)
      expect(response[0]['hits']['hits'].length).to eq(1)
      data = response[0]['hits']['hits'][0]['_source']
      expect(data['title']).to eq('title 1')
      expect(data['num']).to eq(111)
      index_api.insert({
                         index: test_index,
                         id: 2,
                         doc: {
                           title: 'title 2',
                           num: 222
                         }
                       })
      response = utils_api.sql("SELECT * FROM #{test_index}", false)
      datas = response[0]['hits']['hits']
      expect(datas.length).to eq(2)
    end

    it 'delete table will encounter ApiException' do
      expect { utils_api.sql("DELETE FROM #{test_index}") }.to raise_error(Manticoresearch::ApiException)
    end
  end
end

# manticoresearch-ruby

## Installation

Add this line to your application's Gemfile:

```
gem 'manticoresearch', git: 'https://github.com/Athsus/manticoresearch-ruby.git'
```

## Usage

This is an example of how to use the ManticoreSearch Ruby client to perform bulk indexing operations.

```ruby
require 'manticoresearch'

configuration = Manticoresearch::Configuration.new
client = Manticoresearch::ApiClient.new(configuration)
index_api = Manticoresearch::IndexApi.new(client)

# Create a new index
index_api.create_index({ index: 'test_index' })

# Insert a document
index_api.insert({ index: 'test_index', doc: { title: 'Hello, World!', num: 1 } })

# Perform a search
search_api = Manticoresearch::SearchApi.new(client)
search_results = search_api.search({ index: 'test_index', query: { match: { title: 'Hello' } } })

# Perform a SQL query
sql_api = Manticoresearch::UtilsApi.new(client)
sql_results = sql_api.sql({ index: 'test_index', query: 'SELECT * FROM test_index' })

# Delete a document
index_api.delete({ index: 'test_index', query: { match: { title: 'Hello' } } })

# bulk insert multiple documents
docs = [
    {
        insert: {
            index: 'test_index',
            doc: {
                title: 'test1',
                num: 1
            }
        }
    },
    {
        insert: {
            index: 'test_index',
            doc: {
                title: 'test2', 
                num: 2
            }
        }
    }
]
index_api.bulk(docs)
```

More examples can be found in the [examples](./examples) folder.

## API Documentation

All URIs are relative to `http://127.0.0.1:9308`.

### API Endpoints

| Class        | Method     | HTTP request                | Description                                      |
|--------------|------------|-----------------------------|--------------------------------------------------|
| **IndexApi** | `bulk`     | **POST** `/bulk`            | Bulk index operations                            |
| **IndexApi** | `delete`   | **POST** `/delete`          | Delete a document in an index                    |
| **IndexApi** | `insert`   | **POST** `/insert`          | Create a new document in an index                |
| **IndexApi** | `replace`  | **POST** `/replace`         | Replace a document in an index                   |
| **IndexApi** | `update`   | **POST** `/update`          | Update a document in an index                    |
| **SearchApi** | `percolate` | **POST** `/pq/{index}/search` | Perform reverse search on a percolate index    |
| **SearchApi** | `search`  | **POST** `/search`          | Performs a search on an index                    |
| **UtilsApi** | `sql`      | **POST** `/sql`             | Perform SQL queries                              |


For full API reference, please refer to the [Manticore Search Documentation](https://manual.manticoresearch.com).

## Contributing

### Bug reports

If you discover any bugs, feel free to create an issue on GitHub. Please add as much information as, including your gem version, Ruby version, and operating system, and steps to reproduce the issue.

### Feature requests
1. Fork it (<https://github.com/Athsus/manticoresearch-ruby/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Ao Yu](https://github.com/Athsus) - creator and maintainer

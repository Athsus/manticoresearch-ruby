require 'httparty'
require 'json'
require 'uri'

module Manticoresearch
  # RESTResponse class for handling REST API responses
  class RESTResponse
    attr_accessor :status, :reason, :data, :headers

    def initialize(response)
      @status = response.code
      @reason = response.message
      @data = response.body
      @headers = response.headers
    end

    def getheaders
      @headers
    end

    def getheader(name, default_value = nil)
      @headers[name] || default_value
    end
  end

  # RESTClientObject class for making REST API requests
  class RESTClientObject
    # Initialize with a configuration
    def initialize(configuration)
      @configuration = configuration
      uri = URI.parse(@configuration.host)
      host = uri.host || 'localhost'
      port = uri.port || 9208
      scheme = uri.scheme || 'http'

      @base_uri = "#{scheme}://#{host}:#{port}"
    end

    def request(method, url, query_params = nil, headers = nil, body = nil)
      # 设置 headers 和参数
      headers ||= {}
      full_url = @base_uri + url

      options = {
        headers: headers
      }

      # 添加查询参数
      options[:query] = query_params if query_params && !query_params.empty?

      # 设置请求体
      if body
        options[:body] = body.is_a?(String) ? body : body.to_json
        headers['Content-Type'] ||= 'application/json'
      end

      # 发送请求
      response = HTTParty.send(method.downcase, full_url, options)

      rest_response = RESTResponse.new(response)

      # 输出调试信息
      puts 'REST Response:'
      puts "Status: #{rest_response.status}"
      puts "Reason: #{rest_response.reason}"
      puts "Data: #{rest_response.data}"
      puts "Headers: #{rest_response.headers}"

      raise ApiException, response if rest_response.status < 200 || rest_response.status >= 300

      puts 'success'

      rest_response
    end
  end
end

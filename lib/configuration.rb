require 'logger'
require 'base64'

module Manticoresearch
  # Configuration class for Manticoresearch client
  class Configuration
    JSON_SCHEMA_VALIDATION_KEYWORDS = %w[
      multipleOf
      maximum
      exclusiveMaximum
      minimum
      exclusiveMinimum
      maxLength
      minLength
      pattern
      maxItems
      minItems
    ].freeze

    # Base URL for the API
    attr_accessor :host, :api_key, :api_key_prefix, :username, :password, :client_side_validation,
                  :verify_ssl, :ssl_ca_cert, :cert_file, :key_file, :assert_hostname, :logger,
                  :debug, :connection_pool_maxsize, :proxy, :proxy_headers

    # Default settings
    def initialize(host: 'http://127.0.0.1:9308', api_key: {}, api_key_prefix: {}, username: nil, password: nil)
      @host = host
      @api_key = api_key
      @api_key_prefix = api_key_prefix
      @username = username
      @password = password
      set_default_values
      setup_logger
    end

    # Provide a default configuration
    def self.default
      @default ||= Configuration.new
    end

    private

    def set_default_values
      @client_side_validation = true
      @verify_ssl = true
      @ssl_ca_cert = nil
      @cert_file = nil
      @key_file = nil
      set_additional_defaults
    end

    def set_additional_defaults
      @assert_hostname = nil
      @logger = Logger.new($stdout)
      @debug = false
      @connection_pool_maxsize = 20
      @proxy = nil
      @proxy_headers = {}
    end

    # Set the logger's level based on debug settings
    def setup_logger
      @logger.level = if @debug
                        Logger::DEBUG
                      else
                        Logger::INFO
                      end
    end

    # Get API key with optional prefix
    def get_api_key_with_prefix(identifier)
      key = @api_key[identifier]
      prefix = @api_key_prefix[identifier]
      if key && prefix
        "#{prefix} #{key}"
      elsif key
        key
      end
    end

    # Return the basic auth token, base64 encoded
    def basic_auth_token
      return unless @username && @password

      Base64.strict_encode64("#{@username}:#{@password}")
    end

    # Debug report for logging useful info
    def to_debug_report
      <<-REPORT
      Ruby SDK Debug Report:
      OS: #{`uname -s`.strip}
      Ruby Version: #{RUBY_VERSION}
      Version of the API: 0.0.1
      REPORT
    end

    # Get the host, considering possible settings or options for multiple hosts
    def host_from_settings(_index = 0)
      @host
    end
  end
end

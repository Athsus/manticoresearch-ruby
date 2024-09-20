# frozen_string_literal: true

module Manticoresearch
  # ApiException class for handling API exceptions
  class ApiException < StandardError
    attr_reader :http_resp

    def initialize(http_resp = nil, reason = nil)
      @http_resp = http_resp
      super(reason || http_resp&.message || 'ApiException')
    end
  end
end

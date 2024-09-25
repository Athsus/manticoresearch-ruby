# frozen_string_literal: true

module Manticoresearch
  # ApiException class for handling API exceptions
  class ApiException < StandardError
    attr_reader :status_code

    def initialize(error_message = 'API Error', status_code = 500)
      @status_code = status_code
      super(error_message)
    end
  end

  # ApiValueError class for handling user input errors value
  class ApiValueError < StandardError
    def initialize(reason = nil)
      super(reason || 'ApiValueError')
    end
  end
end

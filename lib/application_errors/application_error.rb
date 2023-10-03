# frozen_string_literal: true

module ApplicationErrors
  class ApplicationError < StandardError
    attr_reader :status, :code

    def initialize(status, code, message)
      super(message)
      @status = status
      @code = code
    end
  end
end

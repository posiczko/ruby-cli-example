# frozen_string_literal: true

module Ruby
  class Error < StandardError
  end

  class ResponseError < Error
    attr_reader :status, :headers, :body

    def initialize(message = nil, status: nil, headers: nil, body: nil)
      super(message)
      @status = status
      @headers = headers
      @body = body
    end
  end
end

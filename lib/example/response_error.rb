# Raised when a remote call fails, carrying the response that caused it.
#
# @example
#   raise(Example::ResponseError.new("Unexpected status", status: 503, body: body))
class Example::ResponseError < Example::Error
  attr_reader :status, :headers, :body

  def initialize(message = nil, status: nil, headers: nil, body: nil)
    super(message)
    @status = status
    @headers = headers
    @body = body
  end
end

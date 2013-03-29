module Poncho
  class Error < StandardError; end

  class UserError < Error
    def initialize(message)
      @message = message
    end

    def to_a
      [403, {}, @message]
    end
  end

  class ResourceError < Error
  end
end
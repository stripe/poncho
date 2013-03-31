module Poncho
  class Error < StandardError; end

  class ServerError < Error
    def code
      500
    end
  end

  class ClientError < Error
    def code
      400
    end
  end

  class ValidationError < ClientError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end

    def code
      406
    end
  end

  class ResourceError < ServerError
  end
end
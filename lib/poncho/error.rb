module Poncho
  class Error < StandardError
    def to_json
      as_json.to_json
    end

    def type
      inspect
    end

    def as_json
      {:error => {:type => type, :message => message}}
    end
  end

  class ServerError < Error
    def code
      500
    end

    def type
      :server_error
    end

    def message
      "Sorry, something went wrong. " +
      "We've been notified about the problem."
    end
  end

  class ResourceValidationError < ServerError
  end

  class ClientError < Error
    attr_reader :type, :message

    def initialize(type = nil, message = nil)
      @type    = type || self.class.name
      @message = message
    end

    def code
      400
    end
  end

  class InvalidRequest < ClientError
  end

  class ValidationError < ClientError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end

    def code
      406
    end

    def as_json
      errors
    end
  end

  class NotFoundError < ClientError
    def code
      404
    end

    def type
      :not_found
    end
  end
end
module Poncho
  class Error < StandardError
    self.attr_reader :error_type, :error_code

    def self.type(type)
      @error_type = type
    end

    def self.code(code)
      @error_code = code
    end

    def type
      self.class.error_type
    end

    def code
      self.class.error_code
    end

    def details
      nil
    end

    def to_hash
      {:error => {:type => type, :message => message, :details => details}}
    end
  end

  class ServerError < Error
    type :server_error
    code 500

    def message
      super || "Sorry, something went wrong. " +
        "We've been notified about the problem."
    end
  end

  class ResourceValidationError < ServerError
    def initialize(errors)
      @errors = errors
    end
  end

  class ClientError < Error
    attr_reader :message

    type :client_error
    code 400

    def initialize(message)
      @message = message
    end
  end

  class InvalidRequest < ClientError
    type :invalid_request

    def initialize(message)
      @message = message
    end
  end

  class ValidationError < ClientError
    attr_reader :errors

    type :validation_error
    code 422

    def initialize(errors)
      @errors = errors
    end

    def details
      errors.to_hash
    end
  end

  class NotFoundError < ClientError
    type :not_found
    code 404
  end
end

module Poncho
  class Error < StandardError
    def self.type(type=nil)
      @type ||= type
    end

    def type
      self.class.type || self.class.superclass.type
    end

    def details
      nil
    end
  end

  class ServerError < Error
    type :server_error
  end

  class ClientError < Error
    type :client_error
  end

  class InvalidRequest < ClientError
    type :invalid_request
  end

  class ValidationError < ClientError
    attr_reader :errors

    type :validation_error

    def initialize(errors)
      @errors = errors
    end

    def details
      errors.to_hash
    end

    def message
      errors.to_s
    end
  end

  class InternalValidationError < ValidationError
    type :server_error
  end

  class NotFoundError < ClientError
    type :not_found
  end
end

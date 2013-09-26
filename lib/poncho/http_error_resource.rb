module Poncho
  class HttpErrorResource < Resource
    param :type
    param :message
    param :details, :type => :hash, :optional => true

    validate do
      unless @raw_record.kind_of?(Poncho::Error)
        errors.add(:base,
          "HttpErrorResponse must be initialized with a Poncho::Error, " +
          "you passed a #{@raw_record.class.name}")
      end
    end

    def describe
      { :error => super }
    end

    def code
      case @raw_record
      when ServerError, InternalValidationError then 500
      when NotFoundError then 404
      when ValidationError then 422
      when InvalidRequest, ClientError then 400
      else
        500
      end
    end

    def describe_message(message)
      if code < 500
        message
      else
        "Sorry, something went wrong."
      end
    end
  end
end

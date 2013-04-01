begin
  require 'json'
rescue LoadError => e
  require 'json/pure'
end

module Poncho
  class JSONMethod < Method
    error 500 do
      body ServerError.new
    end

    error 403 do
      body InvalidRequestError.new
    end

    error 404 do
      body NotFoundError.new
    end

    error ValidationError do
      body env['poncho.error'].errors
    end

    def body(value = nil)
      if value && !value.is_a?(String)
        content_type :json
        value = value.to_json
      end

      super
    end

    def json(value, code = nil)
      content_type :json
      status code if code
      value.to_json
    end

    def json?
      request.accept?(mime_type(:json))
    end
  end
end
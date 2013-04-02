begin
  require 'json'
rescue LoadError => e
  require 'json/pure'
end

module Poncho
  class JSONMethod < Method
    error 500 do
      json ServerError.new
    end

    error 403 do
      json InvalidRequestError.new
    end

    error 404 do
      json NotFoundError.new
    end

    error ValidationError do
      json env['poncho.error'].errors
    end

    def body(value = nil)
      if value && !json_content_type?
        content_type :json
        value = value.to_json
      end

      super
    end

    def json(value)
      content_type :json
      body(value.to_json)
    end

    def json?
      request.accept?(mime_type(:json))
    end

    def json_content_type?
      response['Content-Type'] == mime_type(:json)
    end
  end
end
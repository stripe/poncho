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
      if value && !json_content_type?
        content_type :json
        value = value.to_json
      end

      super
    end

    alias_method :json, :body

    def json?
      request.accept?(mime_type(:json))
    end

    def json_content_type?
      response['Content-Type'] == mime_type(:json)
    end
  end
end
begin
  require 'json'
rescue LoadError => e
  require 'json/pure'
end

module Poncho
  class JSONMethod < Method
    error 500 do
      body(:error => {
        :type    => :server_error,
        :message => 'Sorry, something went wrong.'
      })
    end

    error 403 do
      body(:error => {
        :type    => :client_error,
        :message => 'Invalid request.'
      })
    end

    error 404 do
      body(:error => {
        :type    => :not_found,
        :message => 'Not found'
      })
    end

    error ValidationError do
      body env['poncho.error'].errors
    end

    def body(value = nil)
      if value && !value.is_a?(String)
        content_type :json
        response.body = value.to_json
      elsif value
        response.body = value
      else
        response.body
      end
    end
  end
end
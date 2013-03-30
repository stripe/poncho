begin
  require 'json'
rescue LoadError => e
  require 'json/pure'
end

module Poncho
  class JSONMethod < Method

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
begin
  require 'json'
rescue LoadError => e
  require 'json/pure'
end

module Poncho
  class JSONMethod < Method
    def dispatch!
      content_type :json
      super
    end

    def body(value = nil)
      if value
        value = value.to_json unless value.is_a?(String)
        response.body = value
      else
        response.body
      end
    end
  end
end
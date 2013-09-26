require 'json'

module Poncho
  module Serializer
    module JSON
      def self.dump(resource)
        resource.describe.to_json
      end

      def self.content_type
        'application/javascript'
      end
    end
  end
end

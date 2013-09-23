module Poncho
  module Serializer
    module JSON
      def serialize(resource)
        resource.to_hash.to_json
      end
    end
  end
end

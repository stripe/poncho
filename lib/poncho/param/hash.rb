module Poncho
  module Param
    class HashParam < BaseParam
      def validate_value(converted, raw)
        unless converted.kind_of?(Hash)
          {
            :expected => 'hash',
            :actual => raw.class.name
          }
        end
      end
    end
  end
end

module Poncho
  module Param
    class HashParam < BaseParam
      # TODO: Should be able to specify a list of valid keys
      # (maybe this is through the inclusion validator)
      # Should be able to specify the type of values.
      # Possibly should be able to restrict the type of keys
      # or maybe we should default to only allowing string/symbol keys
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

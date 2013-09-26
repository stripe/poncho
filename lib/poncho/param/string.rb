module Poncho
  module Param
    class StringParam < BaseParam
      def validate_value(converted, raw)
        unless converted.kind_of?(String)
          record.errors.add(attribute,
            "Expected a String or a value that can be converted to a String " +
            "but got a #{raw.class.name}")
        end
      end

      def convert(value)
        value && value.to_s
      end
    end
  end
end

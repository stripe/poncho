module Poncho
  module Param
    class IntegerParam < BaseParam
      def validate_value(converted, raw)
        unless converted.is_a?(Integer)
          {
            :expected => "integer",
            :actual => raw.kind_of?(String) ? raw : raw.class.name
          }
        end
      end

      def convert(value)
        if value.kind_of?(String)
          Integer(value)
        elsif value.kind_of?(Integer)
          value
        else
          nil
        end
      rescue TypeError, ArgumentError
        nil
      end
    end
  end
end

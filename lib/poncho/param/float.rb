module Poncho
  module Param
    class FloatParam < BaseParam
      def validate_value(converted, raw)
        unless converted.is_a?(Float)
          {
            :expected => "floating point number",
            :actual => raw.is_a?(String) ? raw : raw.class.name
          }
        end
      end

      def convert(value)
        if value.kind_of?(String) || value.kind_of?(Numeric)
          Float(value)
        else
          nil
        end
      rescue TypeError, ArgumentError
        nil
      end
    end
  end
end

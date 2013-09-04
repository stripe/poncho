module Poncho
  module Params
    class FloatParam < Param
      def validate_each(record, attribute, value)
        unless convert(value).is_a?(Float)
          record.errors.add(attribute,
            :expected => "floating point number",
            :actual => value.is_a?(String) ? value : value.class.name)
        end
      end

      def convert(value)
        if value.kind_of?(String) || value.kind_of?(Numeric)
          Float(value)
        else
          value
        end
      rescue TypeError, ArgumentError
        nil
      end
    end
  end
end

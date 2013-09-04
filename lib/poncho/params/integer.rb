module Poncho
  module Params
    class IntegerParam < Param
      def validate_each(record, attribute, value)
        converted = convert(value)
        unless converted && converted.is_a?(Integer)
          record.errors.add(attribute,
            :expected => "integer",
            :actual => (value.kind_of?(String) ? value : value.class.name))
        end
      end

      def convert(value)
        if value.kind_of?(String)
          Integer(value)
        else
          value
        end
      rescue TypeError, ArgumentError
        nil
      end
    end
  end
end

module Poncho
  module Params
    class BooleanStringParam < Param
      def validate_each(record, attribute, value)
        converted = convert(value)

        if !(converted.is_a?(TrueClass) || converted.is_a?(FalseClass))
          record.errors.add(attribute, :invalid_boolean_string, options.merge(:value => value))
        end
      end

      def convert(value)
        return true if value == 'true'
        return false if value == 'false'
        nil
      end
    end
  end
end

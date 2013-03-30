module Poncho
  module Params
    class IntegerParam < Param
      def validate_each(record, attribute, value)
        unless convert(value).is_a?(Integer)
          record.errors.add(attribute, :invalid_integer, options.merge(:value => value))
        end
      end

      def convert(value)
        Integer(value)
      rescue TypeError, ArgumentError
        nil
      end
    end
  end
end
module Poncho
  module Params
    class ArrayParam < Param
      def validate_each(record, attribute, value)
        if !value.is_a?(Array)
          record.errors.add(attribute, :invalid_array, options.merge(:value => value))
        end
      end

      def convert(value)
        Array(value)
      end
    end
  end
end
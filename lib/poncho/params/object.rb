module Poncho
  module Params
    class ObjectParam < Param
      def validate_each(record, attribute, value)
        if !value || !value.is_a?(Object)
          record.errors.add(attribute, :invalid_object, options.merge(:value => value))
        end
      end

      def convert(value)
        value
      end
    end
  end
end
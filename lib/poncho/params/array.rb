module Poncho
  module Params
    class ArrayParam < Param
      def validate_each(record, attribute, value)
        unless value.is_a?(Array)
          record.errors.add(attribute, :expected => "array", :actual => value.class.name)
        end
      end

      def convert(value)
        Array(value)
      end
    end
  end
end

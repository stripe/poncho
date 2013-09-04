module Poncho
  module Params
    class BooleanParam < Param
      def validate_each(record, attribute, value)
        if convert(value).nil?
          record.errors.add(attribute, :expected => 'boolean (true or false)', :actual => value.class.name)
        end
      end

      def convert(value)
        if value.is_a?(TrueClass) || value.is_a?(FalseClass)
          value
        else
          nil
        end
      end
    end
  end
end

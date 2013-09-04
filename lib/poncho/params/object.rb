module Poncho
  module Params
    class ObjectParam < Param
      def validate_each(record, attribute, value)
        if value.nil?
          record.errors.add(attribute, "Value must be an object, not nil")
        end
        if !value.is_a?(Object)
          record.errors.add(attribute, :expected => 'Object', :actual => value.class.name)
        end
      end

      def convert(value)
        value
      end
    end
  end
end

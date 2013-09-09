module Poncho
  module Params
    class BooleanParam < Param
      def validate_each(record, attribute, value)
        if convert(value).nil?
          record.errors.add(attribute, :expected => 'boolean (true or false)', :actual => value)
        end
      end

      def convert(value)
        if value.is_a?(TrueClass) || value.is_a?(FalseClass)
          value
        elsif value.is_a?(String)
          value = value.strip.downcase
          return true if ["1", "true"].include?(value)
          return false if ["0", "false"].include?(value)
        elsif value.is_a?(Integer)
          return value != 0
        else
          nil
        end
      end
    end
  end
end

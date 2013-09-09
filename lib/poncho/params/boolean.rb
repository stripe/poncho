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
        elsif ['1', 'true', 'yes', 1].include?(value)
          true
        elsif ['0', 'false', 'no', 0].include?(value)
          false
        else
          nil
        end
      end
    end
  end
end

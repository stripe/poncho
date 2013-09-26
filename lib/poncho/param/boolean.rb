module Poncho
  module Param
    class BooleanParam < BaseParam
      def validate_value(converted, raw)
        unless converted.is_a?(TrueClass) || converted.is_a?(FalseClass)
          {
            :expected => 'boolean (true or false)',
            :actual => raw.is_a?(String) ? raw : raw.class.name
          }
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

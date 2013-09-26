module Poncho
  module Param
    class ArrayParam < BaseParam
      def validate_value(converted, raw)
        unless converted.is_a?(Array)
          { :expected => 'array', :actual => raw.class.name }
        end
      end

      def convert(value)
        if value.is_a?(Array)
          value
        elsif value && value.respond_to?(:to_a)
          value.to_a
        end
      end
    end
  end
end

module Poncho
  module Param
    class StringParam < BaseParam
      def validate_each(record, attribute, value)
        unless value.is_a?(String)
          record.errors.add(attribute, :expected => 'string', :actual => value.class.name)
        end
      end

      def convert(value)
        value && value.to_s
      end
    end
  end
end

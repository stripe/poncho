module Poncho
  module Param
    class ResourceParam < BaseParam
      def initialize(name, options = {})
        super

        unless options[:resource]
          throw ArgumentError, ':resource required'
        end
      end

      def validate_value(converted, raw)
        unless converted.clean
          converted.errors.to_hash.each do |attr, messages|
            record.messages[:"#{attribute}[#{attr}]"] |= messages
         end
        end
      end

      def convert(value)
        options[:resource].new(value)
      end
    end
  end
end

module Poncho
  module Param
    class ResourceParam < BaseParam
      # TODO: Should probably be able to specify a Param type for elements
      # of the array
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
        # TODO: Do we want to include a way to selectively expand subresources
        # vs. just keeping a reference like a primary key?
        options[:resource].new(value)
      end
    end
  end
end

module Poncho
  module Params
    class ResourceParam < Param
      def initialize(name, options = {})
        super

        unless options[:resource]
          throw ArgumentError, ':resource required'
        end
      end

      def validate_each(record, attribute, value)
        resource = convert(value)

        unless resource.valid?
          resource.errors.to_hash.each do |attr, messages|
            record.errors.set(:"#{attribute}[#{attr}]", messages)
         end
        end
      end

      def convert(value)
        options[:resource].new(value)
      end
    end
  end
end
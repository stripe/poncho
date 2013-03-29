module Poncho
  module Validations
    class TypeValidator < EachValidator
      def check_validity!
        raise ArgumentError, 'You must supply an :is option' unless options[:is]
      end

      def validate_each(record, attribute, value)
        unless options[:is] == type_for(value)
          record.errors.add(attribute, :type, options.merge(:value => value))
        end
      end

      private

      def type_for(value)
        # TODO
        :string
      end
    end

    module HelperMethods
      def validates_type_of(*attr_names, options = {})
        validates_with TypeValidator, options.merge(:attributes => attr_names)
      end
    end
  end
end
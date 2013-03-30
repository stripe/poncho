module Poncho
  module Validations
    class ExtraParamsValidator < Validator
      def validate(record)
        if extra_params?(record)
          record.errors.add(:extra_params, 'Too many params')
        end
      end

      private

      def extra_params?(record)
        record.request.params.keys - record.class.params.keys != []
      end
    end

    class ParamValidator < EachValidator
      def validate_each(record, attribute, value)
        record.validate_param(attribute)
      end
    end

    module HelperMethods
      def validates_extra_params
        validates_with ExtraParamsValidator
      end

      def validates_param(*attr_names)
        options = attr_names.last.is_a?(::Hash) ? attr_names.pop : {}
        validates_with ParamValidator, options.merge(:attributes => attr_names)
      end
    end
  end
end
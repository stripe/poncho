module Poncho
  class Method
    module Params
      class BooleanParam < Param
        def validate_each(record, attribute, value)
          converted = convert(value)

          if !(converted.is_a?(TrueClass) || converted.is_a?(FalseClass))
            record.errors.add(attribute, :invalid_boolean, options.merge(:value => value))
          end
        end

        def convert(value)
          if value.is_a?(TrueClass) || value.is_a?(FalseClass)
            return value
          end
          nil
        end
      end
    end
  end
end
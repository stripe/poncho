module Poncho
  class Method
    module Params
      class StringParam < Param
        def validate_each(record, attribute, value)
          unless value.is_a?(String)
            record.errors.add(attribute, :invalid_string, options.merge(:value => value))
          end
        end

        def convert(value)
          value && value.to_s
        end
      end
    end
  end
end
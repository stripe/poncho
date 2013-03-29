module Poncho
  module Method
    module Params
      class BooleanStringParam < Param
        type :boolean_string

        def convert(value)
          return true if value == 'yes'
          return false if value == 'no'
          nil
        end
      end
    end
  end
end
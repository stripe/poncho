module Poncho
  module Method
    module Params
      class StringParam < Param
        type :string

        def convert(value)
          value && value.to_s
        end
      end
    end
  end
end
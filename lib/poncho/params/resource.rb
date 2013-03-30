module Poncho
  module Params
    class ResourceParam < Param
      def initialize(name, options = {})
        super

        unless options[:resource]
          throw ArgumentError, ':resource required'
        end
      end

      def convert(value)
        options[:resource].new(value)
      end
    end
  end
end
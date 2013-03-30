module Poncho
  class Resource
    class Key
      attr_reader :name, :options

      def initialize(name, options = {})
        @name    = name
        @options = options
      end

      def type
        options[:type] || :string
      end

      def convert(value)
        if options[:resource]
          value = options[:resource].new(value)
        end

        value
      end
    end
  end
end
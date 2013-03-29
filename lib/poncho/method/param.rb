module Poncho
  module Method
    class Param
      def self.types
        @types ||= []
      end

      def self.for_type(type)
        types[type] || raise Error, "Unknown type: #{type}"
      end

      def self.type(type = nil)
        @type = type if type
        Param.types[@type] = child
        @type
      end

      attr_reader :name, :options

      def initialize(name, options = {})
        @name    = name.to_sym
        @options = options
      end

      def convert(value)
        value
      end

      def type
        self.class.type
      end
    end
  end
end
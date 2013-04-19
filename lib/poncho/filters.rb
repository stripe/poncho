module Poncho
  module Filters
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end

    class Filter
      attr_reader :options, :block

      def initialize(options = {}, &block)
        @options = options
        @block   = block
      end

      def to_proc
        block.to_proc
      end

      def call(*args)
        block.call(*args)
      end
    end

    module InstanceMethods
      def run_filters(type)
        self.class.run_filters(type, self)
      end
    end

    module ClassMethods
      def filters
        @filters ||= Hash.new {|h, k| h[k] = [] }
      end

      def add_filter(type, options = {}, &block)
        filters[type] << Filter.new(options, &block)
      end

      def run_filters(type, binding = self)
        base = self

        while base.respond_to?(:filters)
          base.filters[type].each {|f| binding.instance_eval(&f) }
          base = base.superclass
        end
      end
    end
  end
end

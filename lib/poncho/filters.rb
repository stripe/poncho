module Poncho
  module Filters
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end

    class Filter
      def initialize(options = {}, &block)
        @options = options
        @block   = block
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
        @filters ||= {}
      end

      def filters_for(type)
        filters[type] ||= []
        filters[type]
      end

      def add_filter(type, options = {}, &block)
        filters_for(type) << Filter.new(options, &block)
      end

      def run_filters(type, *args)
        filters_for(type).each {|f| f.call(*args) }
      end
    end
  end
end
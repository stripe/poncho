module Poncho
  module Returns
    class InvalidReturn < ServerError
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def returns(*resources)
        @returns = resources if resources.any?
        @returns ||= []
      end
    end

    def body(value = nil)
      if value && success? && self.class.returns.none? {|res| value.is_a?(res) }
        raise InvalidReturn, "Invalid body: #{value}"
      end

      super
    end
  end
end
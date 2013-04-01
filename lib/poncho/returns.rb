module Poncho
  module Returns
    class InvalidReturn < ServerError
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def returns(resource = nil)
        @returns = resource if resource
        @returns
      end
    end

    def body(value = nil)
      returns = self.class.returns

      if value && returns && !value.is_a?(returns)
        raise InvalidReturn, "Invalid return: #{value}"
      end

      super
    end
  end
end
module Poncho
  module Params
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def params
        if superclass && superclass.respond_to?(:params)
          superclass.params.merge(_params)
        else
          _params
        end
      end

      def _params
        @params ||= {}
      end

      # TODO: I suggest we deprecate these syntactic sugar methods for now
      # optiona/required/present might be better sugar anyway
      def string(name, options = {})
        param(name, options.merge(:type => :string))
      end

      def integer(name, options = {})
        param(name, options.merge(:type => :integer))
      end

      private

      def param_for_type(type)
        return type if type.is_a?(Class)
        name = type.to_s.split('_').map {|w| w.capitalize }.join
        const_get("#{name}Param")
      rescue NameError
        raise ArgumentError, "Unknown param: #{type}"
      end

    end
  end
end

Dir[File.dirname(__FILE__) + "/params/*.rb"].sort.each do |path|
  filename = File.basename(path)
  require "poncho/params/#{filename}"
end

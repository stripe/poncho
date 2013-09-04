module Poncho
  module Params
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def params
        @params ||= {}
      end

      def param(name, options = {})
        type  =  options[:type]
        type ||= options[:resource] ? :resource : :string

        klass = param_for_type(type)
        param = klass.new(name, options)
        params[param.name] = param

        param
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

    # TODO: Don't like the reference to param_before_type_cast here
    def run_param_validations!
      # Validate method parameters
      self.class.params.each do |attr, param|
        param.validate!(self, param_before_type_cast(attr))
      end
    end

  end
end

Dir[File.dirname(__FILE__) + "/params/*.rb"].sort.each do |path|
  filename = File.basename(path)
  require "poncho/params/#{filename}"
end

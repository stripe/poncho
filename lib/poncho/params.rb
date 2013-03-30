module Poncho
  module Params
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      VALIDATES_DEFAULT_KEYS = [:type, :required, :format, :in, :not_in, :length]

      def params
        @params ||= {}
      end

      def param(name, options = {})
        klass = param_for_type(options[:type] || :string)
        param = klass.new(name, options)
        params[param.name] = param
        create_validations_for(param)
        param
      end

      def string(name, options = {})
        param(name, options.merge(:type => :string))
      end

      def integer(name, options = {})
        param(name, options.merge(:type => :integer))
      end

      private

      def param_for_type(type)
        return type if type.is_a?(Param)
        name = type.to_s.split('_').map {|w| w.capitalize }.join
        const_get("#{name}Param")
      rescue NameError
        raise ArgumentError, "Unknown param: #{type}"
      end

      def create_validations_for(param)
        attribute = param.name

        unless param.options[:validate_type] == false
          validates_param(attribute, :param => param)
        end

        if param.options[:required]
          validates_presence_of(attribute)
        end

        if param.options[:format]
          validates_format_of(attribute, :with => param.options[:format])
        end

        if param.options[:in]
          validates_inclusion_of(attribute, :in => param.options[:in])
        end

        if param.options[:not_in]
          validates_exclusion_of(attribute, :in => param.options[:not_in])
        end

        if param.options[:length]
          length_options = case param.options[:length]
          when Integer
            {:minimum => 0, :maximum => param.options[:length]}
          when Range
            {:within => param.options[:length]}
          when Hash
            param.options[:length]
          end
          validates_length_of(attribute, length_options)
        end

        validators = param.options.reject {|key, _| VALIDATES_DEFAULT_KEYS.include?(key) }
        validates(attribute, validators) if validators.any?
      end
    end
  end
end

require 'poncho/validations'

Dir[File.dirname(__FILE__) + "/params/*.rb"].sort.each do |path|
  filename = File.basename(path)
  require "poncho/params/#{filename}"
end
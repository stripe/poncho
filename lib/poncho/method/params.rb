module Poncho
  module Method
    module Params
      def params
        @params ||= {}
      end

      def param(name, options = {})
        klass = Param.for_type(options[:type] || :string)

        param = klass.new(name, options)
        params[param.name] = param
        create_validations_for(param)
        param
      end

      protected

      def create_validations_for(param)
        attribute = param.name

        if param.options[:validate]
          validates_with(param.options[:validate], :attributes => [param])
        end

        if param.options[:required]
          validates_presence_of(attribute)
        end

        if param.options[:numeric]
          validates_numericality_of(attribute, number_options)
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
      end
    end
  end
end
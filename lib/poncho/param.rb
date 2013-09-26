module Poncho
  module Param
    class BaseParam
      include Validation::Methods
      include Validation::Helpers

      def self.type
        @type ||= begin
                    full_name = name.split('::').last
                    full_name = full_name.gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase
                    full_name.sub(/_param$/, '').to_sym
                  end
      end

      attr_reader :name, :options

      def initialize(name, options = {})
        @name    = name.to_sym
        @options = options
        create_validations
      end

      def type
        self.class.type
      end

      def attribute
        @options[:attribute] || @name
      end

      def validate_param(record, converted, raw)
        if Poncho::Validation::PresenceValidator.is_empty_value?(raw)
          # TODO: should this just be validated here as opposed to in a validator?
          @presence_validator.validate(record) unless @presence_validator.nil?
        else
          err = validate_value(converted, raw) # Param-specific validation
          if err
            record.errors.add(@name, err)
          else
            validators.each{|v| v.call(record) }
          end
        end
      end

      def convert(value)
        value
      end

      def validate_value(converted, raw); end

      def create_validations
        unless @options[:optional]
          @presence_validator = Poncho::Validation::PresenceValidator.new(
            :attributes => [@name])
        end

        if @options[:format]
          validates_format_of(@name, :with => @options[:format], :message => @options[:message])
        end

        if @options[:in]
          validates_inclusion_of(@name, :in => @options[:in])
        end

        if @options[:not_in]
          validates_exclusion_of(@name, :in => @options[:not_in])
        end

        if @options[:length]
          length_options = case @options[:length]
                           when Integer
                             {:minimum => 0, :maximum => @options[:length]}
                           when Range
                             {:within => @options[:length]}
                           when Hash
                             @options[:length]
                           end
          validates_length_of(@name, length_options)
        end

        if @options[:validate_with]
          validates_with(@options[:validate_with], :attributes => [@name])
        end
      end
    end
  end
end

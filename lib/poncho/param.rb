module Poncho
  class Param
    include InstanceValidations

    VALIDATES_DEFAULT_KEYS = [:resource, :type, :required, :format, :in, :not_in, :length, :message]

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

    def validate!(record, raw_value)
      if Poncho::Validations::PresenceValidator.is_empty_value?(raw_value)
        # TODO: should this just be validated here as opposed to in a validator?
        @presence_validator.validate(record) unless @presence_validator.nil?
      else
        validate_each(record, @name, raw_value) # Param-specific validation
        validators.each{|v| v.call(record) }
      end
    end

    def convert(value)
      value
    end

    # TODO: This should be renamed
    def validate_each(record, attribute, value); end

    def create_validations

      if @options[:required]
        @presence_validator = Poncho::Validations::PresenceValidator.new(
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

      validators = @options.reject {|key, _| VALIDATES_DEFAULT_KEYS.include?(key) }
      validators.each do |v, opts|
        case opts
        when false
          return
        when true
          opts = {}
        when Symbol
          opts = {opts => true}
        end

        validates(@name, v, opts)
      end
    end
  end
end

module Poncho
  class Resource
    include Validation

    # TODO: Should we explicitly validate the list of options passed?
    # TODO: Should the second argument be a required type instead of making
    # type part of the options and defaulting to string?
    def self.param(name, options = {})
      name = name.to_sym
      type  =  options[:type]
      type ||= options[:resource] ? :resource : :string

      klass = param_class_for_type(type)
      param = klass.new(name, options)
      _params[param.name] = param

      param
    end

    def self.params
      if superclass && superclass.respond_to?(:params)
        superclass.params.merge(_params)
      else
        _params
      end
    end

    def self._params
      @_params ||= {}
    end

    def self.param_class_for_type(type)
      return type if type.is_a?(Class)
      name = type.to_s.split('_').map {|w| w.capitalize }.join
      begin
        Poncho::Param.const_get("#{name}Param")
      rescue NameError => e
        raise ArgumentError, "Unknown param: #{type}"
      end
    end

    def initialize(record)
      if record.nil?
        raise ServerError.new("Invalid nil value passed to initalizer for #{self.class.name}.")
      end

      @raw_record = record
    end

    def clean!
      raise ValidationError.new(errors) unless clean
      self
    end

    def clean
      @record = {}
      self.class.params.each do |attr, param|
        if respond_to?("read_#{param.attribute}")
          raw_value = send("read_#{param.attribute}")
        else
          raw_value = read_raw_value(param.attribute)
        end

        @record[attr] = param.convert(raw_value)
      end

      if valid?
        self
      end
    end

    def record
      if @record.nil?
        raise ServerError.new("Attempted to access record before calling 'clean'. " +
          "You must call 'clean' before trying to access data on a Poncho::Resource.")
      end

      @record
    end

    # Params

    def [](name)
      unless record.key?(name)
        raise ServerError.new("Undefined parameter #{name}")
      end

      value = record[name]

      if respond_to?("describe_#{name}")
        send("describe_#{name}", value)
      else
        record[name]
      end
    end

    def param?(name)
      record.key?(name)
    end
    alias_method :key?, :param?

    def each
      record.keys.each do |key|
        yield key, self[key]
      end
    end

    # Serialization

    def to_hash
      hash = {}

      each do |key, value|
        if value.respond_to?(:to_hash)
          value = value.to_hash
        end
        hash[key] = value
      end

      hash
    end

    alias_method :describe, :to_hash

    # Validation

    def run_validations
      self.class.params.each do |attr, param|
        param.validate_param(self, self[attr], read_raw_value(param.attribute))
      end
      super
    end

    def read_attribute_for_validation(name)
      record[name]
    end

    protected

    def read_raw_value(name)
      if @raw_record.respond_to?(:[])
        return @raw_record[name.to_sym] if @raw_record.key?(name.to_sym)
        return @raw_record[name.to_s] if @raw_record.key?(name.to_s)
      elsif @raw_record.respond_to?(name)
        @raw_record.send(name)
      end
    end
  end
end

module Poncho
  class Resource
    include Validation

    attr_reader :record

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
        puts e
        raise ArgumentError, "Unknown param: #{type}"
      end
    end

    def initialize(record)
      if record.nil?
        raise ResourceValidationError, "Invalid nil value passed to initalizer for #{self.class.name}."
      end

      @record = record
    end

    # Params

    def [](name)
      param = self.class.params[name.to_sym]
      raise Error, "Undefined param #{name}" unless param
      param.convert(param_before_type_cast(name))
    end

    def param_before_type_cast(name)
      # TODO: Get rid of all this type guessing
      if record.kind_of?(Hash) # TODO: Should this be duck-typed?
        return record[name.to_sym] if record.key?(name.to_sym)
        return record[name.to_s] if record.key?(name.to_s)
      elsif record.respond_to?(name)
        record.send(name)
      end
    end

    alias_method :param?, :respond_to?

    # Serialization

    def to_hash
      hash = {}
      self.class.params.keys.each do |key|
        hash[key] = self[key]
      end

      hash
    end

    alias_method :describe, :to_hash

    # Validation

    alias_method :read_attribute_for_validation, :[]

    def run_validations
      self.class.params.each do |attr, param|
        param.validate_param(self, param_before_type_cast(attr))
      end
      super
    end
  end
end

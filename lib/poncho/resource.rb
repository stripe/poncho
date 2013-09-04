module Poncho
  class Resource
    include Params
    include ClassValidations

    attr_reader :record

    def initialize(record)
      if record.nil?
        raise ResourceValidationError, "Invalid nil value passed to initalizer for #{self.class.name}."
      end

      @record = record
    end

    # Params

    def param(name)
      param = self.class.params[name]
      raise Error, "Undefined param #{name}" unless param
      param.convert(param_before_type_cast(name))
    end

    def param_before_type_cast(name)
      if record.kind_of?(Hash) # Should we duck-type this?
        record[name.to_sym] || record[name.to_s]
      elsif record.respond_to?(name)
        record.send(name)
      end
    end

    alias_method :param?, :respond_to?

    # Serialization

    def each
      [to_json]
    end

    def to_json(*)
      run_validations!
      to_hash.to_json
    end

    def to_hash
      self.class.params.keys.inject({}) do |hash, key|
        hash[key] = send(key)
        hash
      end
    end

    alias_method :describe, :to_hash

    # Validation

    # We want to validate an attribute if its
    # uncoerced value is not nil
    def param_for_validation?(name)
      if respond_to?(name)
        !send(name).nil?
      else
        !param_before_type_cast(name).nil?
      end
    end

    alias_method :read_attribute_for_validation, :send

    def validate!
      raise ResourceValidationError.new(errors.to_s) unless run_validations!
    end

    def run_validations!
      run_param_validations!
      super
    end

    def method_missing(method_symbol, *arguments) #:nodoc:
      if self.class.params.keys.include?(method_symbol)
        return param(method_symbol)
      end

      super
    end
  end
end

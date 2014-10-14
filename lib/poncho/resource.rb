module Poncho
  class Resource
    include Params
    include Validations

    attr_reader :record

    def initialize(record)
      if record.nil?
        raise ResourceValidationError, 'Invalid nil record'
      end

      @record = record.is_a?(Hash) ? record.symbolize_keys : record
    end

    # Params

    def param(name)
      param = self.class.params[name]
      raise Error, "Undefined param #{name}" unless param
      param.convert(param_before_type_cast(name))
    end

    def param_before_type_cast(name)
      case record
      when Hash
        record[name]
      else
        record.send(name) if record.respond_to?(name)
      end
    end

    alias_method :param?, :respond_to?

    # Serialization

    def each
      [to_json]
    end

    def to_json(*)
      as_json.to_json
    end

    def as_json(options = nil)
      validate!
      to_hash
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
      raise ResourceValidationError, errors.to_s unless valid?
    end

    def method_missing(method_symbol, *arguments) #:nodoc:
      if self.class.params.keys.include?(method_symbol)
        return param(method_symbol)
      end

      super
    end
  end
end
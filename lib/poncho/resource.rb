module Poncho
  class Resource
    include Validations
    extend Keys

    attr_reader :record

    def initialize(record)
      @record = record
    end

    def each
      [to_json]
    end

    def keys
      self.class.keys
    end

    def read_key(name)
      unless self.keys.has_key?(name)
        raise ResourceError, "Unknown key: #{name}"
      end

      value = record.send(name)
      self.keys[name].convert(value)
    end

    def read_key_before_type_cast(name)
      record.send(name)
    end

    def validate!
      raise ResourceError, errors.first unless valid?
    end

    def as_json(options = nil)
      validate!
      keys.keys.map({}) do |hash, key|
        hash[key] = send(key)
        hash
      end
    end
  end
end
module Poncho
  class Param
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
    end

    def type
      self.class.type
    end

    def validate(record)
      value = record.param_before_type_cast(name)
      validate_each(record, name, value) unless value.nil?
    end

    def validate_each(record, attribute, value)
    end

    def convert(value)
      value
    end
  end
end
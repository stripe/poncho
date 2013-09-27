module Poncho
  class Method
    include Filters

    def self._resource_class(resource_type, resource, block)
      if resource && block
        raise ArgumentError("Cannot pass both a resource and a block to `#{resource_type}`")
      end

      if resource.nil? && block.nil?
        raise ArgumentError("Must pass either a resource or a block to `#{resource_type}`")
      end

      class_getter = "#{resource_type}_class".to_sym
      if superclass &&
          superclass.respond_to?(class_getter) &&
          superclass.send(class_getter)
        if resource
          raise ArgumentError("Cannot pass a resource to `` if a superclass " +
            "has `accepts` defined.  Please pass a block or inherit from a superclass " +
            "that doesn't define `accepts`")
        end
        base = superclass.send(class_getter)
      else
        base = Resource
      end

      if resource
        resource
      else
        Class.new(base, &block)
      end
    end

    def self.accepts(resource = nil, &block)
      @accepts_class ||= _resource_class(:accepts, resource, block)
    end

    def self.returns(resource = nil, &block)
      @returns_class ||= _resource_class(:returns, resource, block)
    end

    def self.accepts_class
      @accepts_class
    end

    def self.returns_class
      @returns_class || Resource
    end

    # Filters

    def self.before(options = {}, &block)
      add_filter(:before, options, &block)
    end

    def self.after(options = {}, &block)
      add_filter(:after, options, &block)
    end

    def self.error_handlers
      @error_handlers ||= {}
    end

    def self.error(type = :base, &block)
      error_handlers[type] = block
    end

    def self.helpers(*extensions, &block)
      class_eval(&block)   if block_given?
      include(*extensions) if extensions.any?
    end

    # TODO: Do we really want to support options here?
    # it's a little like a method having two different
    # sets of arguments.  Also, YAGNI.
    def initialize(options={})
      @options = options
    end

    def call(params={})
      check_extra_params!(params)

      argument_resource = self.class.accepts_class.new(params)
      argument_resource.clean!

      returned = dispatch!(argument_resource)
      return_resource = self.class.returns_class.new(returned)

      unless return_resource.clean
        raise InternalValidationError.new(return_resource.errors)
      end

      return_resource
    end

    # Implement

    def invoke(argument_resource)
      raise NotImplementedError
    end

    protected

    def check_extra_params!(params)
      extras = params.keys.reject{|param| self.class.accepts_class.params.has_key?(param.to_sym) }
      if extras.count > 0
        raise ClientError.new("Unexpected parameter(s), do not include any of '#{extras.join(', ')}' in your request.")
      end
    end

    # Calling

    def dispatch!(argument_resource)
      run_filters :before
      invoke(argument_resource)
    ensure
      run_filters :after
    end

    def error_block(key)
      base = self.class

      while base.respond_to?(:error_handlers)
        block = base.error_handlers[key]
        return block if block
        base = base.superclass
      end

      return false unless key.respond_to?(:superclass) && key.superclass < Exception
      error_block(key.superclass)
    end
  end
end

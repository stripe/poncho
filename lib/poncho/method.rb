module Poncho
  class Method
    include ClassValidations
    include Filters
    include Params

    self.attr_reader :args_class, :returns_class

    def self.call(params = {})
      self.new(params).call
    end

    # Some magic so you can do one-line
    # Sinatra routes. For example:
    #   get '/charges', &ChargesListMethod
    def self.to_proc
      this = self
      Proc.new { this.call(params) }
    end

    def self._resource_class(resource_type, resource, block)
      if resource && block
        raise ArgumentError("Cannot pass both a resource and a block to `#{resource_type}`")
      end

      if resource.nil? && block.nil?
        raise ArgumentError("Must pass either a resource or a block to `#{resource_type}`")
      end

      class_getter = "#{resource_type}_class".to_sym
      if superclass &&
          superclass.respond_to?(class_getter_name) &&
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

    def self.accepts(resource=nil, &block)
      @accepts_class = _parameter_class(:accepts, resource, block)
    end

    def self.returns(resource, &block)
      @returns_class = _parameter_class(:returns, resource, block)
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

    def initialize(options={})
      @options = options
      wrap {
      }
    end

    def call(params={})
      wrap {
        run_extra_param_validations!(params)

        argument_resource = self.class.accepts_class.new(params)
        unless argument_resource.valid?
          raise ValidationError.new(argument_resource.errors.to_s)
        end

        returned = dispatch!(argument_resource)
        response = self.class.returns_class.new(returned)
        unless response.valid?
          raise ResourceValidationError(response.errors)
        end
      }
      response
    end

    # Implement

    def invoke(argument_resource)
      raise NotImplementedError
    end

    protected

    def run_extra_param_validations!(params)
      extras = params.reject{|param| self.accepts_class.params.has_key?(param.to_sym) }
      if extras
        raise ValidationError.new("Unexpected parameter(s), do not include any of '#{extras.join(', ')}' in your request.")
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

    def handle_exception!(error)
      # Exception raised in error handling
      raise error if @poncho_error
      @poncho_error = error

      status = error.respond_to?(:code) ? Integer(error.code) : 500

      block   = error_block(error.class)
      block ||= error_block(status)
      block ||= error_block(:base)

      if block
        wrap {
          instance_eval(&block)
        }
      else
        raise error
      end
    end

    def wrap
      yield
    rescue ::Exception => e
      handle_exception!(e)
    end
  end
end

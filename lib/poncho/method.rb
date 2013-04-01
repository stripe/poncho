module Poncho
  class Method
    include Validations
    include Filters
    include Params

    def self.call(env)
      self.new.call(env)
    end

    # Some magic so you can do one-line
    # Sinatra routes. For example:
    #   get '/charges', &ChargesListMethod
    def self.to_proc
      this = self
      Proc.new { this.call(env) }
    end

    # Filters

    def self.before(options = {}, &block)
      add_filter(:before, options, &block)
    end

    def self.before_validation(options = {}, &block)
      add_filter(:before_validation, options, &block)
    end

    def self.errors
      @errors ||= {}
    end

    def self.error(type = :base, &block)
      errors[type] = block
    end

    def self.helpers(*extensions, &block)
      class_eval(&block)   if block_given?
      include(*extensions) if extensions.any?
    end

    attr_reader :env, :request, :response

    def call(env)
      @env      = env
      @request  = Request.new(env)
      @response = Response.new

      wrap {
        validate!
        dispatch!
      }

      unless @response['Content-Type']
        if Array === body and body[0].respond_to? :content_type
          content_type body[0].content_type
        else
          content_type :html
        end
      end

      @response.finish
    end

    def headers(hash=nil)
      response.headers.merge! hash if hash
      response.headers
    end

    def params
      request.params.inject({}) do |hash, (key, _)|
        hash[key.to_sym] = param(key)
        hash
      end
    end

    def param(name)
      param = self.class.params[name.to_sym]
      raise Error, "Undefined param #{name}" unless param
      param.convert(param_before_type_cast(name))
    end

    def param?(name)
      request.params.has_key?(name.to_s)
    end

    def param_before_type_cast(name)
      request.params[name.to_s]
    end

    def status(value=nil)
      response.status = value if value
      response.status
    end

    def redirect(uri, *args)
      if env['HTTP_VERSION'] == 'HTTP/1.1' and env['REQUEST_METHOD'] != 'GET'
        status 303
      else
        status 302
      end
      response['Location'] = uri
      halt(*args)
    end

    def content_type(type = nil, params={})
      return response['Content-Type'] unless type
      default = params.delete :default
      mime_type = mime_type(type) || default
      fail "Unknown media type: %p" % type if mime_type.nil?
      response['Content-Type'] = mime_type.dup
    end

    def body(value=nil, &block)
      if block_given?
        def block.each; yield(call) end
        response.body = block
      elsif value
        response.body = value
      else
        response.body
      end
    end

    def json(value, code = nil)
      content_type :json
      status code if code
      value.to_json
    end

    def json?
      request.accept?(mime_type(:json))
    end

    # Statuses

    # whether or not the status is set to 2xx
    def success?
      status.between? 200, 299
    end

    # whether or not the status is set to 3xx
    def redirect?
      status.between? 300, 399
    end

    # whether or not the status is set to 4xx
    def client_error?
      status.between? 400, 499
    end

    # whether or not the status is set to 5xx
    def server_error?
      status.between? 500, 599
    end

    # whether or not the status is set to 404
    def not_found?
      status == 404
    end

    # Errors

    def halt(*response)
      response = response.first if response.length == 1
      throw :halt, response
    end

    def error(code, body=nil)
      code, body = 500, code.to_str if code.respond_to? :to_str
      self.body(body) unless body.nil?
      halt code
    end

    def not_found(body=nil)
      error 404, body
    end

    # Implement

    def invoke
    end

    # Validation

    alias :read_attribute_for_validation :param_before_type_cast
    alias :param_for_validation? :param?

    protected

    def validate!
      run_filters :before_validation
      run_extra_param_validations!
      run_validations!
      raise ValidationError.new(errors) unless errors.empty?
    ensure
      run_filters :after_validation
    end

    def run_extra_param_validations!
      request.params.keys.each do |param|
        unless self.class.params.has_key?(param.to_sym)
          errors.add(param, :invalid_param)
        end
      end
    end

    # Calling

    def dispatch!
      run_filters :before
      halt invoke
    ensure
      run_filters :after
    end

    def error_block(key)
      base = self.class

      while base.respond_to?(:errors)
        block = base.errors[key]
        return block if block
        base = base.superclass
      end

      return false unless key.respond_to?(:superclass) && key.superclass < Exception
      error_block(key.superclass)
    end

    def handle_exception!(error)
      env['poncho.error'] = error

      status error.respond_to?(:code) ? Integer(error.code) : 500

      if server_error?
        request.logger.error(
          "#{error.class}: #{error}\n\t" +
          error.backtrace.join("\n\t")
        )
      end

      block   = error_block(error.class)
      block ||= error_block(status)
      block ||= error_block(:base)

      if block
        halt instance_eval(&block)
      end

      if server_error?
        body '<h1>Server Error</h1>'
      end

      if not_found?
        headers['X-Cascade'] = 'pass'
        body '<h1>Not Found</h1>'
      end
    end

    def wrap
      res = catch(:halt) { yield }
      res = [res] if Fixnum === res or String === res
      if Array === res and Fixnum === res.first
        status(res.shift)
        body(res.pop)
        headers(*res)
      elsif res.respond_to? :each
        body res
      end
    rescue ::Exception => e
      handle_exception!(e)
    end

    def mime_type(type, value=nil)
      return type if type.nil? || type.to_s.include?('/')
      type = ".#{type}" unless type.to_s[0] == ?.
      return Rack::Mime.mime_type(type, nil) unless value
      Rack::Mime::MIME_TYPES[type] = value
    end
  end
end
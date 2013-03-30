require 'poncho/method/validations'

module Poncho
  class Method
    autoload :Param, 'poncho/method/param'
    autoload :Params, 'poncho/method/params'

    include Poncho::Validations
    include Poncho::Filters
    include Params

    def self.call(env)
      self.new.call(env)
    end

    # Filters

    def self.before(options = {}, &block)
      add_filter(:before, options, &block)
    end

    def self.before_validation(options = {}, &block)
      add_filter(:before_validation, options, &block)
    end

    def self.after(options = {}, &block)
      add_filter(:after, options, &block)
    end

    validates_extra_params

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

    def param(name)
      param = self.class.params[name]
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

    alias :read_attribute_for_validation :param

    def validate_param(name)
      return unless param?(name)
      param = self.class.params[name]
      raise Error, "Undefined param #{name}" unless param
      param.validate(self)
    end

    protected

    def validate!
      run_filters :before_validation
      error(406, errors) unless valid?
    end

    # Calling

    def dispatch!
      run_filters :before
      result = invoke
      run_filters :after

      throw :halt, result
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
    end

    def mime_type(type, value=nil)
      return type if type.nil? || type.to_s.include?('/')
      type = ".#{type}" unless type.to_s[0] == ?.
      return Rack::Mime.mime_type(type, nil) unless value
      Rack::Mime::MIME_TYPES[type] = value
    end
  end
end
require 'poncho'
require 'poncho/serializer/json'

# TODO: Verify extensibility:
# How would we adapt this to support async?
# How would we handle gating access to methods based on their opts
# and an authorization key. (e.g. allow publishable key access to certain methods)
# How would we handle taking out a lock based on a combination of method,
# options and the request parameters (dont_lock_method)
module Poncho::Handler
  module Sinatra
    module Helpers
      def response_from_poncho_resource(resource, status)
        serializer = env['poncho.serializer']
        body = serializer.dump(resource)
        [status, {'Content-type' => serializer.content_type}, body]
      end
    end

    def poncho(opts = {}, &block)
      handler = PonchoHandler.new(self, opts)
      handler.instance_eval(&block)
    end

    def self.registered(app)
      app.helpers(Poncho::Handler::Sinatra::Helpers)

      app.error(Poncho::Error) do |boom|
        response_resource = Poncho::HttpErrorResource.new(boom).clean!
        response_from_poncho_resource(response_resource, response_resource.code)
      end
    end

    class PonchoHandler
      SINATRA_PARAMS = %w{splat captures action controller}

      def initialize(app, opts = {})
        @options = opts
        @app = app
      end

      def serializer(s)
        @options[:serializer] = s
      end

      # Defining a `GET` handler also automatically defines
      # a `HEAD` handler.
      def get(path, api_method, opts = {})
        route(:get, path, api_method, opts)
        route(:head, path, api_method, opts)
      end

      def put(path, api_method, opts = {})     route :put,     path, api_method, opts end
      def post(path, api_method, opts = {})    route :post,    path, api_method, opts end
      def delete(path, api_method, opts = {})  route :delete,  path, api_method, opts end
      def head(path, api_method, opts = {})    route :head,    path, api_method, opts end
      def options(path, api_method, opts = {}) route :options, path, api_method, opts end
      def patch(path, api_method, opts = {})   route :patch,   path, api_method, opts end
      def link(path, api_method, opts = {})    route :link,    path, api_method, opts end
      def unlink(path, api_method, opts = {})  route :unlink,  path, api_method, opts end

      def route(http_method, path, api_method, opts)
        unless api_method <= Poncho::Method
          raise ArgumentError.new("Method must be a Poncho::Method not #{api_method.class.name}")
        end

        handler_options = @options
        @app.send(http_method, path) do
          serializer = handler_options[:serializer] || settings.poncho_serializer
          # TODO: Move serializer stuff to a helper
          unless serializer
            raise ServerError.new("You set a poncho serializer. " +
              "You can pass it as an option to your 'poncho' call " +
              " or set a default for your entire app by calling " +
              " `set :poncho_serializer MY_SERIALIZER` in your configuration")
          end

          if serializer.respond_to?(:call)
            serializer = serializer.call(env, options)
          end

          unless serializer.respond_to?(:dump)
            raise ServerError.new("Your serializer must have a `dump` method " +
              "that accepts a Poncho::Resource and returns a string.")
          end
          unless serializer.respond_to?(:content_type)
            raise ServerError.new("Your serializer must have a `content_type` " +
              "property that returns a string.")
          end

          env['poncho.serializer'] = serializer

          method_params = params.reject{|k| SINATRA_PARAMS.include?(k) }

          response_resource = api_method.new(opts).call(method_params)

          response_from_poncho_resource(response_resource, 200)
        end
      end
    end
  end
end

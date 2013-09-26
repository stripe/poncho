require 'poncho'
require 'poncho/serializer/json'

module Poncho::Handler
  module Sinatra
    def poncho(serializer, &block)
      handler = PonchoHandler.new(serializer, self)
      handler.instance_eval(&block)
    end

    class PonchoHandler
      SINATRA_PARAMS = %w{splat captures action controller}

      def initialize(serializer, app)
        @serializer = serializer
        @app = app
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

        serializer = @serializer
        @app.send(http_method, path) do
          method_params = params.reject{|k| SINATRA_PARAMS.include?(k) }

          begin
            response_resource = api_method.new(opts).call(method_params)
            code = 200
          rescue Poncho::Error => e
            response_resource = Poncho::HttpErrorResource.new(e).clean!
            code = response_resource.code
          end

          body = serializer.dump(response_resource)

          # TODO: serializer should know about content-type
          [code, {'Content-type' => serializer.content_type}, body]
        end
      end
    end
  end
end

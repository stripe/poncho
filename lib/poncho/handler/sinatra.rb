require 'poncho'

module Poncho
  module Handler
    module Sinatra
      def poncho(&block)
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
          route('GET', path, api_method, opts)
          route('HEAD', path, api_method, opts)
        end

        def put(path, api_method, opts = {})     route 'PUT',     path, api_method, opts end
        def post(path, api_method, opts = {})    route 'POST',    path, api_method, opts end
        def delete(path, api_method, opts = {})  route 'DELETE',  path, api_method, opts end
        def head(path, api_method, opts = {})    route 'HEAD',    path, api_method, opts end
        def options(path, api_method, opts = {}) route 'OPTIONS', path, api_method, opts end
        def patch(path, api_method, opts = {})   route 'PATCH',   path, api_method, opts end
        def link(path, api_method, opts = {})    route 'LINK',    path, api_method, opts end
        def unlink(path, api_method, opts = {})  route 'UNLINK',  path, api_method, opts end

        def route(http_method, path, api_method, opts)
          unless api_method <= Poncho::Method
            raise ArgumentError.new("Method must be a Poncho::Method not #{api_method.class.name}")
          end

          app.route(http_method, path) do
            method_params = params.reject{|k| SINATRA_PARAMS.include?(k) }
            response_resource = api_method.new(opts).call(method_params)
          end
        end
      end
    end
  end
end

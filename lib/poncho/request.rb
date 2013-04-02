module Poncho
  class Request < Rack::Request
    # Returns an array of acceptable media types for the response
    def accept
      @env['poncho.accept'] ||= begin
        entries = @env['HTTP_ACCEPT'].to_s.split(',')
        entries.map { |e| accept_entry(e) }.sort_by(&:last).map(&:first)
      end
    end

    def preferred_type(*types)
      return accept.first if types.empty?
      types.flatten!
      accept.detect do |pattern|
        type = types.detect { |t| File.fnmatch(pattern, t) }
        return type if type
      end
    end

    alias accept? preferred_type
    alias secure? ssl?

    def forwarded?
      @env.include? 'HTTP_X_FORWARDED_HOST'
    end

    def safe?
      get? or head? or options? or trace?
    end

    def idempotent?
      safe? or put? or delete?
    end

    def params
      @params ||= begin
        params = super.merge(action_dispatch_params)
        indifferent_params(params)
      end
    end

    private

    # Enable string or symbol key access to the nested params hash.
    def indifferent_params(params)
      params = indifferent_hash.merge(params)
      params.each do |key, value|
        next unless value.is_a?(Hash)
        params[key] = indifferent_params(value)
      end
    end

    # Creates a Hash with indifferent access.
    def indifferent_hash
      Hash.new {|hash,key| hash[key.to_s] if Symbol === key }
    end

    # Pass in params from Rails routing
    def action_dispatch_params
      action_dispatch_params = env['action_dispatch.request.path_parameters'] || {}
      action_dispatch_params.inject({}) {|hash, (key, value)| hash[key.to_s] = value; hash }
    end

    def accept_entry(entry)
      type, *options = entry.delete(' ').split(';')
      quality = 0 # we sort smallest first
      options.delete_if { |e| quality = 1 - e[2..-1].to_f if e.start_with? 'q=' }
      [type, [quality, type.count('*'), 1 - options.size]]
    end
  end
end
module Poncho
  class ErrorHash
    def initialize(base)
      @base     = base
      @messages = {}
    end

    # Clear the messages
    def clear
      @messages.clear
    end

    # When passed a symbol or a name of a method, returns an array of errors
    # for the method.
    #
    #   p.errors[:name]   # => ["can not be nil"]
    #   p.errors['name']  # => ["can not be nil"]
    def [](attribute)
      @messages[attribute.to_sym] ||= []
    end

    def to_s
      full_messages.join('; ')
    end

    def to_hash
      @messages.to_hash
    end

    # Returns true if no errors are found, false otherwise.
    # If the error message is a string it can be empty.
    def empty?
      @messages.all?{ |attribute, messages| messages.nil? || messages.empty? }
    end

    def add(attribute=:base, message_or_opts={})
      case message_or_opts
      when String
        message = message_or_opts
        opts = {}
      when Hash
        message = nil
        opts = message_or_opts
      else
        raise ArgumentError.new("Second argument must be a message string or options hash")
      end

      if message.nil? && opts[:expected]
          message = "Must be a valid #{opts[:expected]}"
          message << " but was #{opts[:actual]}" if opts[:actual]
          message << "."
      end

      self[attribute] << message.to_s
    end

    def full_messages
      @messages.map { |attribute, message| full_message(attribute, message) }
    end

    def full_message(attribute, message)
      return message if attribute == :base
      "#{attribute} is invalid: #{message.join(' ')}"
    end
  end
end

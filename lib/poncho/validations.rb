module Poncho
  # == Active Model Validations
  #
  # Provides a full validation framework to your objects.
  #
  # A minimal implementation could be:
  #
  #   class Person
  #     include ActiveModel::Validations
  #
  #     attr_accessor :first_name, :last_name
  #
  #     validates_each :first_name, :last_name do |record, attr, value|
  #       record.errors.add attr, 'starts with z.' if value.to_s[0] == ?z
  #     end
  #   end
  #
  # Which provides you with the full standard validation stack that you
  # know from Active Record:
  #
  #   person = Person.new
  #   person.valid?                   # => true
  #   person.invalid?                 # => false
  #
  #   person.first_name = 'zoolander'
  #   person.valid?                   # => false
  #   person.invalid?                 # => true
  #   person.errors                   # => #<OrderedHash {:first_name=>["starts with z."]}>
  #
  # Note that <tt>ActiveModel::Validations</tt> automatically adds an +errors+ method
  # to your instances initialized with a new <tt>ActiveModel::Errors</tt> object, so
  # there is no need for you to do this manually.
  #
  module Validations
    def self.included(base)
      base.extend ClassMethods
      base.extend HelperMethods
    end

    module HelperMethods
    end

    module ClassMethods

      VALIDATES_DEFAULT_KEYS = [:if, :unless, :on, :allow_blank, :allow_nil , :strict]

      # Validates each attribute against a block.
      #
      #   class Person
      #     include ActiveModel::Validations
      #
      #     attr_accessor :first_name, :last_name
      #
      #     validates_each :first_name, :last_name do |record, attr, value|
      #       record.errors.add attr, 'starts with z.' if value.to_s[0] == ?z
      #     end
      #   end
      #
      # Options:
      # * <tt>:on</tt> - Specifies the context where this validation is active
      #   (e.g. <tt>:on => :create</tt> or <tt>:on => :custom_validation_context</tt>)
      # * <tt>:allow_nil</tt> - Skip validation if attribute is +nil+.
      # * <tt>:allow_blank</tt> - Skip validation if attribute is blank.
      # * <tt>:if</tt> - Specifies a method, proc or string to call to determine
      #   if the validation should occur (e.g. <tt>:if => :allow_validation</tt>,
      #   or <tt>:if => Proc.new { |user| user.signup_step > 2 }</tt>). The method,
      #   proc or string should return or evaluate to a true or false value.
      # * <tt>:unless</tt> - Specifies a method, proc or string to call to determine if the validation should
      #   not occur (e.g. <tt>:unless => :skip_validation</tt>, or
      #   <tt>:unless => Proc.new { |user| user.signup_step <= 2 }</tt>). The
      #   method, proc or string should return or evaluate to a true or false value.
      def validates_each(*attr_names, &block)
        options = attr_names.last.is_a?(::Hash) ? attr_names.pop : {}
        validates_with BlockValidator, options.merge(:attributes => attr_names.flatten), &block
      end

      # Adds a validation method or block to the class. This is useful when
      # overriding the +validate+ instance method becomes too unwieldy and
      # you're looking for more descriptive declaration of your validations.
      #
      # This can be done with a symbol pointing to a method:
      #
      #   class Comment
      #     include ActiveModel::Validations
      #
      #     validate :must_be_friends
      #
      #     def must_be_friends
      #       errors.add(:base, "Must be friends to leave a comment") unless commenter.friend_of?(commentee)
      #     end
      #   end
      #
      # With a block which is passed with the current record to be validated:
      #
      #   class Comment
      #     include ActiveModel::Validations
      #
      #     validate do |comment|
      #       comment.must_be_friends
      #     end
      #
      #     def must_be_friends
      #       errors.add(:base, "Must be friends to leave a comment") unless commenter.friend_of?(commentee)
      #     end
      #   end
      #
      # Or with a block where self points to the current record to be validated:
      #
      #   class Comment
      #     include ActiveModel::Validations
      #
      #     validate do
      #       errors.add(:base, "Must be friends to leave a comment") unless commenter.friend_of?(commentee)
      #     end
      #   end
      #
      def validate(proc = nil, &block)
        proc ||= block
        proc = method(proc) if proc.is_a?(Symbol)

        validators << proc
      end

      # List all validators that are being used to validate the model using
      # +validates_with+ method.
      def validators
        @validators ||= []
      end

      def validates_with(*args, &block)
        options = args.last.is_a?(::Hash) ? args.pop : {}

        args.each do |klass|
          validator = klass.new(options, &block)
          validate(validator)
        end
      end

      def validates(*attributes)
        options = attributes.last.is_a?(::Hash) ? attributes.pop : {}

        validations = options.reject {|key, value| VALIDATES_DEFAULT_KEYS.include?(key) || !value }
        options     = options.merge(:attributes => attributes)

        validations.each do |key, validator_options|
          validator_options = {} if validator_options == true
          validates_with(validator_for_kind(key), validator_options.merge(:attributes => attributes))
        end
      end

      private

      def validator_for_kind(kind)
        return kind if kind.is_a?(Validator)
        name = kind.to_s.split('_').map {|w| w.capitalize }.join
        const_get("#{name}Validator")
      rescue NameError
        raise ArgumentError, "Unknown validator: #{kind}"
      end
    end

    # Returns the +Errors+ object that holds all information about attribute error messages.
    def errors
      @errors ||= Errors.new(self)
    end

    # Runs all the specified validations and returns true if no errors were added
    # otherwise false. Context can optionally be supplied to define which callbacks
    # to test against.
    def valid?(context = nil)
      errors.clear

      self.class.validators.each do |validator|
        validator.validate(self)
      end

      errors.empty?
    end

    # Performs the opposite of <tt>valid?</tt>. Returns true if errors were added,
    # false otherwise.
    def invalid?
      !valid?
    end

    alias :read_attribute_for_validation :send
  end
end

Dir[File.dirname(__FILE__) + "/validations/*.rb"].sort.each do |path|
  filename = File.basename(path)
  require "poncho/validations/#{filename}"
end
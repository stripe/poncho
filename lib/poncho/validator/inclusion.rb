module Poncho
  module Validations
    class InclusionValidator < EachValidator
      def check_validity!
        if options.key?(:in) && options.key?(:not_in)
          raise ArgumentError.new("You cannot specify both an :in and :not_in " +
            "option for the configuration hash.")
        end
        unless delimiter.respond_to?(:call) or delimiter.respond_to?(:include?)
            raise ArgumentError.new("An object with the method #include? or a proc " <<
              "or lambda is required, and must be supplied as the :in or :not_in " <<
              "option of the configuration hash.")
        end
      end

      # In Ruby 1.9 <tt>Range#include?</tt> on non-numeric ranges checks all possible
      # values in the range for equality, so it may be slow for large ranges. The new
      # <tt>Range#cover?</tt> uses the previous logic of comparing a value with the
      # range endpoints.
      def validate_each(record, attribute, value)
        clusions = delimiter.respond_to?(:call) ? delimiter.call(record) : delimiter

        if exclusion?
          msg = validate_exclusion(clusions, value)
        else
          msg = validate_inclusion(clusions, value)
        end

        if msg
          record.errors.add(attribute, msg)
        end
      end

      def validate_inclusion(record, inclusions, value)
        if inclusions.is_a?(Range) && !inclusions.cover?(value)
          "You supplied '#{value}' but the value must be in the range " +
            "#{inclusions.min} through #{inclusions.max}."
        elsif !inclusions.include?(value)
          "You supplied '#{value}' but the value must be one of: #{inclusions.join(", ")}."
        end
      end

      def validate_exclusion(record, exclusions, value)
        if exclusions.is_a?(Range) && exclusions.cover?(value)
          "You supplied '#{value}' but the value cannot be in the range " +
            "#{exclusions.min} through #{exclusions.max}."
        elsif exclusions.include?(value)
          "You supplied '#{value}' but the value cannot be one of: #{exclusions.join(", ")}."
        end
      end

      private

      def delimiter
        @delimiter ||= options[:in] || options[:not_in]
      end

      def exclusion?
        !options[:in]
      end

    end

    module Helpers
      # Validates whether the value of the specified attribute is available in a
      # particular enumerable object.
      #
      #   class Person < ActiveRecord::Base
      #     validates_inclusion_of :gender, :in => %w( m f )
      #     validates_inclusion_of :age, :in => 0..99
      #     validates_inclusion_of :format, :in => %w( jpg gif png ), :message => "extension %{value} is not included in the list"
      #     validates_inclusion_of :states, :in => lambda{ |person| STATES[person.country] }
      #   end
      #
      # Configuration options:
      # * <tt>:in</tt> - An enumerable object of available items. This can be
      #   supplied as a proc or lambda which returns an enumerable. If the enumerable
      #   is a range the test is performed with <tt>Range#cover?</tt>
      #   (backported in Active Support for 1.8), otherwise with <tt>include?</tt>.
      # * <tt>:message</tt> - Specifies a custom error message (default is: "is not
      #   included in the list").
      # * <tt>:allow_nil</tt> - If set to true, skips this validation if the attribute
      #   is +nil+ (default is +false+).
      # * <tt>:allow_blank</tt> - If set to true, skips this validation if the
      #   attribute is blank (default is +false+).
      # * <tt>:on</tt> - Specifies when this validation is active. Runs in all
      #   validation contexts by default (+nil+), other options are <tt>:create</tt>
      #   and <tt>:update</tt>.
      # * <tt>:if</tt> - Specifies a method, proc or string to call to determine if
      #   the validation should occur (e.g. <tt>:if => :allow_validation</tt>, or
      #   <tt>:if => Proc.new { |user| user.signup_step > 2 }</tt>). The method, proc
      #   or string should return or evaluate to a true or false value.
      # * <tt>:unless</tt> - Specifies a method, proc or string to call to determine
      #   if the validation should not occur (e.g. <tt>:unless => :skip_validation</tt>,
      #   or <tt>:unless => Proc.new { |user| user.signup_step <= 2 }</tt>). The method,
      #   proc or string should return or evaluate to a true or false value.
      # * <tt>:strict</tt> - Specifies whether validation should be strict.
      #   See <tt>Poncho::Validation#validates!</tt> for more information.
      def validates_inclusion_of(*attr_names)
        options = attr_names.last.is_a?(::Hash) ? attr_names.pop : {}
        validates_with InclusionValidator, options.merge(:attributes => attr_names)
      end

      # Validates that the value of the specified attribute is not in a particular
      # enumerable object.
      #
      #   class Person < ActiveRecord::Base
      #     validates_exclusion_of :username, :not_in => %w( admin superuser ), :message => "You don't belong here"
      #     validates_exclusion_of :age, :not_in => 30..60, :message => "This site is only for under 30 and over 60"
      #     validates_exclusion_of :format, :not_in => %w( mov avi ), :message => "extension %{value} is not allowed"
      #     validates_exclusion_of :password, :not_in => lambda { |p| [p.username, p.first_name] },
      #                            :message => "should not be the same as your username or first name"
      #   end
      #
      # Configuration options:
      # * <tt>:not_in</tt> - An enumerable object of items that the value shouldn't be
      #   part of. This can be supplied as a proc or lambda which returns an enumerable.
      #   If the enumerable is a range the test is performed with <tt>Range#cover?</tt>
      #   (backported in Active Support for 1.8), otherwise with <tt>include?</tt>.
      # * <tt>:message</tt> - Specifies a custom error message (default is: "is reserved").
      # * <tt>:allow_nil</tt> - If set to true, skips this validation if the attribute
      #   is +nil+ (default is +false+).
      # * <tt>:allow_blank</tt> - If set to true, skips this validation if the
      #   attribute is blank (default is +false+).
      # * <tt>:on</tt> - Specifies when this validation is active. Runs in all
      #   validation contexts by default (+nil+), other options are <tt>:create</tt>
      #   and <tt>:update</tt>.
      # * <tt>:if</tt> - Specifies a method, proc or string to call to determine if the
      #   validation should occur (e.g. <tt>:if => :allow_validation</tt>, or
      #   <tt>:if => Proc.new { |user| user.signup_step > 2 }</tt>). The method, proc
      #   or string should return or evaluate to a true or false value.
      # * <tt>:unless</tt> - Specifies a method, proc or string to call to determine if
      #   the validation should not occur (e.g. <tt>:unless => :skip_validation</tt>,
      #   or <tt>:unless => Proc.new { |user| user.signup_step <= 2 }</tt>). The method,
      #   proc or string should return or evaluate to a true or false value.
      # * <tt>:strict</tt> - Specifies whether validation should be strict.
      #   See <tt>Poncho::Validation#validates!</tt> for more information.
      def validates_exclusion_of(*attr_names)
        options = attr_names.last.is_a?(::Hash) ? attr_names.pop : {}
        validates_with ExclusionValidator, options.merge(:attributes => attr_names)
      end

    end
  end
end

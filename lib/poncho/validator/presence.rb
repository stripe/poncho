module Poncho
  module Validation
    class PresenceValidator < EachValidator
      def validate_each(record, attribute, value)
        if self.class.is_empty_value?(value)
          record.errors.add(attribute, "Missing required value for #{attribute}")
        end
      end

      def self.is_empty_value?(value)
        value.nil? || (value.respond_to?(:empty?) && value.empty?)
      end
    end

    module Helpers
      # Validates that the specified attributes are not blank (as defined by
      # Object#blank?). Happens by default on save. Example:
      #
      #   class Person < ActiveRecord::Base
      #     validates_presence_of :first_name
      #   end
      #
      # The first_name attribute must be in the object and it cannot be blank.
      #
      # If you want to validate the presence of a boolean field (where the real values
      # are true and false), you will want to use <tt>validates_inclusion_of :field_name,
      # :in => [true, false]</tt>.
      #
      # This is due to the way Object#blank? handles boolean values:
      # <tt>false.blank? # => true</tt>.
      #
      # Configuration options:
      # * <tt>:message</tt> - A custom error message (default is: "can't be blank").
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
      def validates_presence_of(*attr_names)
        options = attr_names.last.is_a?(::Hash) ? attr_names.pop : {}
        validates_with PresenceValidator, options.merge(:attributes => attr_names)
      end
    end
  end
end

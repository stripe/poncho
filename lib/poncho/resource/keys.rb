module Poncho
  class Resource
    module Keys
      VALIDATES_DEFAULT_KEYS = [:type, :required, :format, :in, :not_in, :length]

      def keys
        @keys ||= {}
      end

      def key(name, options = {})
        key        = Key.new(name, options)
        keys[name] = key
        create_validations_for(key)
        create_accessors_for(key)
        key
      end

      protected

      def create_validations_for(key, options = {})
        attribute = key.name

        if key.options[:required]
          validates_presence_of(attribute)
        end

        if key.options[:format]
          validates_format_of(attribute, :with => key.options[:format])
        end

        if key.options[:in]
          validates_inclusion_of(attribute, :in => key.options[:in])
        end

        if key.options[:not_in]
          validates_exclusion_of(attribute, :in => key.options[:not_in])
        end

        if key.options[:length]
          length_options = case key.options[:length]
          when Integer
            {:minimum => 0, :maximum => key.options[:length]}
          when Range
            {:within => key.options[:length]}
          when Hash
            key.options[:length]
          end
          validates_length_of(attribute, length_options)
        end

        validators = key.options.reject {|key, _| VALIDATES_DEFAULT_KEYS.include?(key) }
        validates(attribute, validators) if validators.any?
      end

      def create_accessors_for(key)
        class_eval <<-EOF
          def #{key.name}
            read_key(:#{key.name})
          end

          def #{key.name}_before_type_cast
            read_key_before_type_cast(:#{key.name})
          end
        EOF
      end
    end
  end
end
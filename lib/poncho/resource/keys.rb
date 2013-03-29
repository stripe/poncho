module Poncho
  module Resource
    module Keys
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
        if key.options[:required]
          validates_presence_of(key)
        end

        if key.options[:numeric]
          validates_numericality_of(key, number_options)
        end

        if key.options[:format]
          validates_format_of(key, :with => key.options[:format])
        end

        if key.options[:in]
          validates_inclusion_of(key, :in => key.options[:in])
        end

        if key.options[:not_in]
          validates_exclusion_of(key, :in => key.options[:not_in])
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
          validates_length_of(key, length_options)
        end
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
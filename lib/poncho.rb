require 'poncho/version'

module Poncho
  autoload :Error, 'poncho/error'

  autoload :Errors, 'poncho/errors'
  autoload :Filters, 'poncho/filters'

  autoload :Method, 'poncho/method'

  module Method
    autoload :Param, 'poncho/method/param'

    module Params
      autoload :BooleanString, 'poncho/method/params/boolean_string'
      autoload :String, 'poncho/method/params/string'
      autoload :Params 'poncho/method/params'
    end
  end

  module Resource
    autoload :Key, 'poncho/resource/key'
    autoload :Keys, 'poncho/resource/keys'
  end

  autoload :Resource, 'poncho/resource'

  module Validations
    autoload :Format, 'poncho/validations/format'
    autoload :Inclusions, 'poncho/validations/inclusions'
    autoload :Length, 'poncho/validations/length'
    autoload :Presence, 'poncho/validations/presence'
    autoload :Type, 'poncho/validations/type'
  end

  autoload :Validations, 'poncho/validations'
  autoload :Validator, 'poncho/validator'
end

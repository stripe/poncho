require 'poncho/version'

module Poncho
  autoload :Error, 'poncho/error'

  autoload :Errors, 'poncho/errors'
  autoload :Filters, 'poncho/filters'

  autoload :Validator, 'poncho/validator'
  autoload :Validations, 'poncho/validations'
  autoload :EachValidator, 'poncho/validator'
  autoload :BlockValidator, 'poncho/validator'

  autoload :Method, 'poncho/method'
  autoload :JSONMethod, 'poncho/json_method'

  autoload :Resource, 'poncho/resource'
  autoload :Request, 'poncho/request'
  autoload :Response, 'poncho/response'
end
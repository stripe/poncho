require 'poncho/version'

module Poncho
  autoload :Error, 'poncho/error'
  autoload :ResourceError, 'poncho/error'
  autoload :ClientError, 'poncho/error'
  autoload :ServerError, 'poncho/error'
  autoload :ValidationError, 'poncho/error'

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
  autoload :Param, 'poncho/param'
  autoload :Params, 'poncho/params'
end
require 'poncho/version'

module Poncho
  autoload :Error, 'poncho/error'
  autoload :ResourceValidationError, 'poncho/error'
  autoload :ClientError, 'poncho/error'
  autoload :ServerError, 'poncho/error'
  autoload :ValidationError, 'poncho/error'

  autoload :ErrorHash, 'poncho/error_hash'

  autoload :Filters, 'poncho/filters'

  autoload :Validation, 'poncho/validation'

  autoload :Validator, 'poncho/validator'
  autoload :EachValidator, 'poncho/validator'
  autoload :BlockValidator, 'poncho/validator'

  autoload :Method, 'poncho/method'
  autoload :JSONMethod, 'poncho/json_method'

  autoload :Resource, 'poncho/resource'
  autoload :Request, 'poncho/request'
  autoload :Response, 'poncho/response'
  autoload :Returns, 'poncho/returns'
  autoload :Param, 'poncho/param'
  autoload :Params, 'poncho/params'
end

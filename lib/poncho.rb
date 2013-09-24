require 'poncho/version'

module Poncho
  autoload :Error, 'poncho/error'
  autoload :ResourceValidationError, 'poncho/error'
  autoload :ClientError, 'poncho/error'
  autoload :ServerError, 'poncho/error'
  autoload :ValidationError, 'poncho/error'

  autoload :Filters, 'poncho/filters'
  autoload :ErrorHash, 'poncho/error_hash'
  autoload :Validation, 'poncho/validation'

  autoload :Validator, 'poncho/validator'
  autoload :EachValidator, 'poncho/validator'
  autoload :BlockValidator, 'poncho/validator'

  autoload :Method, 'poncho/method'
  autoload :Resource, 'poncho/resource'
  autoload :Param, 'poncho/param'
end

Dir[File.dirname(__FILE__) + "/poncho/param/*.rb"].sort.each do |path|
  filename = File.basename(path)
  require "poncho/param/#{filename}"
end

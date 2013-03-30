require 'sinatra'
require 'poncho'

module Poncho
  module Validations
    class CardHashValidator < EachValidator
      def validate_each(record, attribute, value)
        if !value.is_a?(Hash)
          record.errors.add(attribute, :invalid_card, options.merge(:value => value))
        end
      end
    end

    class CurrencyValidator < EachValidator
      def validate_each(record, attribute, value)
        if value && !['USD', 'GBP'].include?(value)
          record.errors.add(attribute, :invalid_currency, options.merge(:value => value))
        end
      end
    end
  end
end

class ChargeListMethod < Poncho::JSONMethod
  param :page, :type => :integer, :required => true
  param :currency, :currency => true

  def invoke
    {:hi => 'there'}
  end
end

class ChargeCreateMethod < Poncho::Method
  param :amount, :type => :integer, :required => true
  param :currency, :currency => true
  param :card

  validates :card, CardHashValidator

  def invoke
    'ok'
  end
end

get '/charges' do
  ChargeListMethod.call(env)
end

# post '/charges', &ChargeCreateMethod
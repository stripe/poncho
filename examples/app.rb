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

class ChargeCreateMethod < Poncho::JSONMethod
  param :amount, :type => :integer, :required => true
  param :currency, :currency => true
  param :card

  def invoke
    ChargeResource.new(Charge.new(5, 'GBP'))
  end
end

class Card
  attr_reader :number

  def initialize(number)
    @number = number
  end
end

class Charge
  attr_reader :amount, :currency

  def initialize(amount, currency)
    @amount = amount
    @currency = currency
  end

  def card
    Card.new('4242 4242 4242 4242')
  end
end

class CardResource < Poncho::Resource
  param :number
  param :expiry_month

  def number
    super[-4..-1]
  end
end

class ChargeResource < Poncho::Resource
  param :amount, :type => :integer
  param :currency
  param :card, :resource => CardResource

  def currency
    super || 'USD'
  end
end

get '/charges' do
  ChargeCreateMethod.call(env)
end

# post '/charges', &ChargeCreateMethod
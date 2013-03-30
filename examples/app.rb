require 'sinatra'
require 'poncho'

class ChargeListMethod < Poncho::JSONMethod
  def invoke
    {:hi => 'there'}
  end
end

class ChargeCreateMethod < Poncho::JSONMethod
  param :amount, :type => :integer, :required => true
  param :currency, :in => ['GBP', 'USD']
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
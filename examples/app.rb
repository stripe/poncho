require 'sinatra'
require 'poncho'

class ChargeResource < Poncho::Resource
  key :name
  key :currency, :validate => :currency
end

class ChargeListMethod < Poncho::Method
  def invoke

  end
end

class ChargeCreateMethod < Poncho::Method
  param :amount, :required => true, :numeric => true
  param :currency, :validate => :currency
  param :card, :validate => :card_hash

  def invoke


    ChargeResource.new(record)
  end
end

get '/charges', ChargeListMethod
post '/charges', ChargeCreateMethod
# Poncho

Poncho is an API to build APIs or, in other words, a DSL to build REST interfaces.

It'll validate input and output, coerce values and is easily extendable with custom data types.

## Installation

Add this line to your application's Gemfile:

    gem 'poncho'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install poncho

## Usage

    class ChargeResource < Poncho::Resource
      param :amount, :type => :integer
      param :currency

      def currency
        super || 'USD'
      end
    end

    class ChargeCreateMethod < Poncho::JSONMethod
      param :amount, :type => :integer, :required => true
      param :currency, :in => ['USD', 'GBP']

      def invoke
        charge = Charge.new
        charge.amount = param(:amount)
        charge.currency = param(:currency)
        charge.save

        ChargeResource.new(charge)
      end
    end

    post '/charges', &ChargeCreateMethod
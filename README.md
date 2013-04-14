# Poncho

Poncho is an API to build APIs or, in other words, a DSL to build REST interfaces.

It'll validate input and output, coerce values and is easily extendable with custom data types.

It's compatible with any rack-based framework, such as Rails or Sinatra.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'poncho'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install poncho

## TLDR Usage

```ruby
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
```

## Getting started with Methods

Methods inherit from `Poncho::Method` and override `invoke`, where they perform any necessary logic.

In a similar vein to Sinatra, anything returned from `invoke` is sent right back to the user. You can
return a http status code, a body string, or even a Rack response array.

```ruby
class UsersListMethod < Poncho::Method
  def invoke
    # Some DB shizzle

    200
  end
end
```

To invoke the method just add it to your routes.

Using Rails:

```ruby
match '/users' => UsersListMethod, :via => :get
```

Using Sinatra:

```ruby
get '/users', &UsersListMethod
```

Or invoke manually:

```ruby
UsersListMethod.call(rack_env)
```

If you're writing a JSON API, you'll probably want to inherit the Method from `Poncho::JSONMethod` instead of
`Poncho::Method`, but we'll cover that later.

## Params

You can get access to the request params, via the `params` or `param(name)` methods.

Before you can use a `param` though, you need to define it:

```ruby
param :param_name
```

By default, `param` are of type 'string'. You can choose a different type via the `:type` option:

```ruby
param :amount, :type => :integer
```

There are a bunch of predefined types, such as `:integer`, `:array`, `:boolean_string` etc, but you can
also easily define your own custom ones (covered later).

Poncho will automatically validate that if a parameter is provided it is in a valid format.
Poncho will also handle type conversion for you.

So for example, in the case above, Poncho will automatically validate that the `amount` param is
indeed an Integer or an Integer string, and will coerce the parameter into an Integer when you try to access it.

## Validation

As well as the default type validation, Poncho lets you validate presence, format, length and much more!

For example, to validate that a `:currency` parameter is provided, pass in the `:presence` option:

```ruby
param :currency, :presence => true
```

To validate that a currency is either 'USD' or 'GBP', use the `:in` option.

```ruby
param :currency, :in => ['USD', 'GBP']
```

The other supported validations out of the box are `:format`, `:not_in`, and `:length`:

```ruby
param :email, :format => /@/
param :password, :length => 5..20
```

## Custom Validation

You can use a custom validator via the `validate` method, passing in a block:

```ruby
validate do
  unless param(:customer_id) ~= /\Acus_/
    errors.add(:customer_id, :invalid_customer)
  end
end
```

Or

```ruby
validates :customer_id, :customer_validate
```

Alternatively, if your validation is being used in multiple places, you can wrap it up in a class and
pass it to the `validates_with` method.

```ruby
validates_with CustomValidator
```

For a good example of how to build validations, see the [
existing ones](https://github.com/stripe/poncho/tree/master/lib/poncho/validations).

## Custom Params

As your API grows you'll probably start to need custom parameter types. These can be useful to ensure
parameters are both valid and converted into suitable values.

To define a custom parameter, simply inherit from `Poncho::Param`. For example, let's define a new parameter called
`CardHashParam`. It needs to validate input via overriding the `validate_each` method, and convert input via
overriding the `convert` method.

```ruby
module Poncho
  module Params
    class CardHashParam < Param
      def validate_each(method, attribute, value)
        value = convert(value)

        unless value.is_a?(Hash) && value.keys == [:number, :exp_month, :exp_year, :cvc]
          method.errors.add(attribute, :invalid_card_hash, options.merge(:value => value))
        end
      end

      def convert(value)
        value && value.symbolize_keys
      end
    end
  end
end
```

You can use custom parameters via the `:type` option.

```ruby
param :card, :type => Poncho::Params::CardHashParam

# Or the shortcut
param :card, :type => :card_hash
```

## Request & Response

You can gain access to the rack request via the `request` method, for example:

```ruby
def invoke
 accept = request.headers['Accept']
 200
end
```

The same goes for the response object:

```ruby
def invoke
  response.body = ['Fee-fi-fo-fum']
  200
end
```

There are some helper methods to set such things as the HTTP status response codes and body.

```ruby
def invoke
  status 201
  body 'Created!'
end
```

## Method filters

There are various filters you can apply to the request, for example:

```ruby
class MyMethod < Poncho::Method
  before_validation do
    # Before validation
  end

  before do
    # Before invoke
    p params
  end

  after do
    # After invocation
  end
end
```

## Error responses

You can provide custom responses to exceptions via the `error` class method.

Pass `error` an exception type or status code.

```ruby
class MyMethod < Poncho::Method
  error MyCustomClass do
    'Sorry, something went wrong.'
  end

  error 403 do
    'Not authorized.'
  end
end
```

## JSON APIs

If your API only returns JSON then Poncho has a convenient `JSONMethod` class which
will ensure that all response bodies are converted into JSON and that the correct content type
header is set.

```ruby
class TokenCreateMethod < Poncho::JSONMethod
  param :number, :required => true

  def invoke
    {:token => '123'}
  end
end
```

`JSONMethod` also ensures that there's valid JSON error responses to 404s and 500s, as well
as returning a JSON error hash for validation errors.

```
$ curl http://localhost:4567/tokens -d number={"error":{"param":"number","type":"presence"}
```

## Resources

Resources are wrappers around other classes, such as models, providing a view representation of them.

You can specify attributes to be returned to the client using the same `param` syntax as documented above.

```ruby
class Card
  attr_reader :number

  def initialize(number)
    @number = number
  end
end

class CardResource < Poncho::Resource
  param :number
  param :description

  def number
    super[-4..-1]
  end
end
```

As you can see in the example above, you can override params and return a custom response.

When the `Resource` instance is converted into JSON, the appropriate params will be used and serialized.

```ruby
class ChargeResource < Poncho::Resource
  param :amount, :type => :integer
  param :currency
  param :card, :resource => CardResource

  def currency
    super || 'USD'
  end
end

class ChargeListMethod < Poncho::JSONMethod
  def invoke
    [
      ChargeResource.new(Charge.new(1000, 'USD')),
      ChargeResource.new(Charge.new(50, 'USD'))
    ]
  end
end
```

If a particular param points to another resource, you can use the `:type => :resource` option as demonstrated above.



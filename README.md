# Poncho

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'poncho'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install poncho

## Usage

    get '/charges' do
      ChargeListMethod.call(env)
    end

    class ChargeListMethod < Poncho::Method
      param :blah, :string, :required => true

      def invoke
        charge = Charge.load(param(:id))
        body ChargeResource.new(charge)
      end
    end


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

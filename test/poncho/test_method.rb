require 'minitest/autorun'
require 'rack/mock'
require 'poncho'

class TestMethod < MiniTest::Unit::TestCase
  def env(params = {})
    Rack::MockRequest.env_for('http://api.com/charges', :params => params)
  end

  def setup
  end

  def test_that_integer_params_are_validated
    method = Class.new(Poncho::Method) do
      param :amount, :type => :integer
    end

    status, headers, body = method.call(env(:amount => nil))
    assert_equal 406, status

    status, headers, body = method.call(env(:amount => '1'))
    assert_equal 200, status

    status, headers, body = method.call(env(:amount => 'blah'))
    assert_equal 406, status
  end

  def test_that_string_params_are_validated
    method = Class.new(Poncho::Method) do
      param :amount, :type => :string
    end

    status, headers, body = method.call(env(:amount => nil))
    assert_equal 406, status

    status, headers, body = method.call(env(:amount => 'blah'))
    assert_equal 200, status
  end

  def test_presence_validation
    method = Class.new(Poncho::Method) do
      param :amount, :required => true
    end

    status, headers, body = method.call(env())
    assert_equal 406, status

    status, headers, body = method.call(env(:amount => 'test'))
    assert_equal 200, status
  end

  def test_custom_param_conversion
    custom_param = Class.new(Poncho::Param) do
      def convert(value)
        return true if value == 'custom'
        return false
      end
    end

    method = Class.new(Poncho::Method) do
      param :currency, :type => custom_param

      def invoke
        halt param(:currency) == true ? 200 : 406
      end
    end

    status, headers, body = method.call(env(:currency => 'notcustom'))
    assert_equal 406, status

    status, headers, body = method.call(env(:currency => 'custom'))
    assert_equal 200, status
  end

  def test_custom_param_validation
    custom_param = Class.new(Poncho::Param) do
      def validate_each(record, name, value)
        unless ['USD', 'GBP'].include?(value)
          record.errors.add(name, :invalid_currency)
        end
      end
    end

    method = Class.new(Poncho::Method) do
      param :currency, :type => custom_param
    end

    status, headers, body = method.call(env(:currency => 'RSU'))
    assert_equal 406, status

    status, headers, body = method.call(env(:currency => 'USD'))
    assert_equal 200, status
  end

  def test_json_method_returns_json
    method = Class.new(Poncho::JSONMethod) do
      def invoke
        {:some => 'stuff'}
      end
    end

    status, headers, body = method.call(env())
    assert_equal({:some => 'stuff'}.to_json, body.body.first)
  end
end
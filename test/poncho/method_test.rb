require File.expand_path(File.join(File.dirname(__FILE__), '../_lib'))

require 'rack/mock'

class TestMethod < Test
  def env(params = {})
    Rack::MockRequest.env_for('http://api.com/charges', :params => params)
  end

  def setup
  end

  def test_param_validation
    method = Class.new(Poncho::Method) do
      param :amount, :type => :integer, :required => true
    end

    status, headers, body = method.call(env(:amount => nil))
    assert_equal 422, status

    status, headers, body = method.call(env(:amount => '1'))
    assert_equal 200, status

    status, headers, body = method.call(env(:amount => 'blah'))
    assert_equal 422, status
  end

  def test_presence_validation
    method = Class.new(Poncho::Method) do
      param :amount, :required => true
    end

    status, headers, body = method.call(env())
    assert_equal 422, status

    status, headers, body = method.call(env(:amount => 'test'))
    assert_equal 200, status
  end

  def test_validation_with_optional_parameter
    method = Class.new(Poncho::Method) do
      param :amt, :type => :integer, :in => [1, 2, 3, 4]
    end

    status, headers, body = method.call(env())
    assert_equal(200, status)

    status, headers, body = method.call(env(:amt => '4'))
    assert_equal(200, status, "Unexpected error status with body: #{body.body.first}")

    status, headers, body = method.call(env(:amt => '6'))
    assert_equal(422, status, "Expected 422 but got #{status} with body: #{body.body.first}")
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
        halt param(:currency) == true ? 200 : 422
      end
    end

    status, headers, body = method.call(env(:currency => 'notcustom'))
    assert_equal 422, status

    status, headers, body = method.call(env(:currency => 'custom'))
    assert_equal 200, status
  end

  def test_custom_param_validation
    custom_param = Class.new(Poncho::Param) do
      def validate_each(record, name, value)
        unless ['USD', 'GBP'].include?(value)
          record.errors.add(name, :expected => 'valid currency (either USD or GBP)', :actual => value)
        end
      end
    end

    method = Class.new(Poncho::Method) do
      param :currency, :type => custom_param
    end

    status, headers, body = method.call(env(:currency => 'RSU'))
    assert_equal 422, status

    status, headers, body = method.call(env(:currency => 'USD'))
    assert_equal 200, status
  end

  def test_extra_param_validation
    method = Class.new(Poncho::Method) do
      param :amt, :type => :integer
    end

    status, headers, body = method.call(env(:foo => 'bar'))
    assert_equal(422, status)
  end

  def test_before_filter
    method = Class.new(Poncho::Method) do
      before do
        halt 411
      end

      def invoke
        200
      end
    end

    status, headers, body = method.call(env())
    assert_equal 411 , status
  end

  def test_before_validation_filter
    method = Class.new(Poncho::Method) do
      param :amount, :type => :integer

      before_validation do
        halt 411
      end
    end

    status, headers, body = method.call(env())
    assert_equal 411 , status
  end

  def test_after_validation_filter
    method = Class.new(Poncho::Method) do
      after_validation do
        halt 411
      end

      def invoke
        200
      end
    end

    status, headers, body = method.call(env())
    assert_equal 411 , status
  end

  def test_after_filter
    method = Class.new(Poncho::Method) do
      after do
        halt 411
      end

      def invoke
        200
      end
    end

    status, headers, body = method.call(env())
    assert_equal 411 , status
  end
end

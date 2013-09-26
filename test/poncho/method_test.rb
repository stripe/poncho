require File.expand_path(File.join(File.dirname(__FILE__), '../_lib'))

class TestMethod < Test
  def assert_valid(method_class, params)
    res = method_class.new.call(params)
    assert(res.kind_of?(Poncho::Resource))

    res
  end

  def assert_invalid(method_class, params)
    err = assert_raises(Poncho::ValidationError){method_class.new.call(params)}
    assert_equal(:validation_error, err.type)
  end

  def test_param_validation
    method = Class.new(Poncho::Method) do
      accepts do
        param :amount, :type => :integer
      end

      def invoke(args); {}; end
    end

    assert_valid(method, :amount => '1')

    assert_invalid(method, :amount => nil)
    assert_invalid(method, :amount => 'blah')
  end

  def test_presence_validation
    method = Class.new(Poncho::Method) do
      accepts do
        param :amount
      end

      def invoke(args); {}; end
    end

    assert_valid(method, :amount => 'test')

    assert_invalid(method, {})
  end

  def test_validation_with_optional_parameter
    method = Class.new(Poncho::Method) do
      accepts do
        param :amt, :type => :integer, :in => [1, 2, 3, 4], :optional => true
      end

      def invoke(args); {}; end
    end

    assert_valid(method, {})
    assert_valid(method, :amt => '4')

    assert_invalid(method, :amt => '6')
  end

  def test_custom_param_conversion
    custom_param = Class.new(Poncho::Param::BaseParam) do
      def convert(value)
        return true if value == 'custom'
        return false
      end
    end

    method = Class.new(Poncho::Method) do
      accepts do
        param :cstm, :type => custom_param
      end
      returns do
        param :was_cstm, :type => :boolean
      end

      def invoke(args)
        { :was_cstm => args[:cstm] == true }
      end
    end

    res = assert_valid(method, :cstm => 'notcustom')
    assert_equal(false, res[:was_cstm])

    res = assert_valid(method, :cstm => 'custom')
    assert_equal(true, res[:was_cstm])
  end

  def test_custom_param_validation
    custom_param = Class.new(Poncho::Param::BaseParam) do
      def validate_value(converted, raw)
        unless converted.start_with?('U')
          { :expected => "string beginning with 'U'", :actual => raw }
        end
      end
    end

    method = Class.new(Poncho::Method) do
      accepts do
        param :foo, :type => custom_param
      end

      def invoke(args); {}; end
    end

    assert_valid(method, :foo => 'USD')

    assert_invalid(method, :foo => 'RSU')
  end

  def test_before_filter
    skip
  end

  def test_after_filter
    skip
  end
end

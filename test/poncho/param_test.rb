require File.expand_path(File.join(File.dirname(__FILE__), '../_lib'))

class TestParam < Test
  def test_array_param_validation
    assert(!Poncho::Param::ArrayParam.new('array').validate_value([], []))
    assert(!Poncho::Param::ArrayParam.new('array').validate_value([[:a, 1]], [[:a, 1]]))

    assert_equal(
      { :expected => 'array', :actual => 'String' },
      Poncho::Param::ArrayParam.new('array').validate_value(nil, 'bar')
      )
  end

  def test_array_param_convert
    p = Poncho::Param::ArrayParam.new('p')

    assert_equal([], p.convert([]))
    assert_equal([[:a, 1]], p.convert(:a => 1))

    [nil, 'abc'].each do |v|
      assert_equal(nil, p.convert(v))
    end
  end

  def test_string_param_validation
    assert(!Poncho::Param::StringParam.new('p').validate_value('bar', 'bar'))

    # What doesn't support to_s?
  end

  def test_boolean_param_validation
    assert(!Poncho::Param::BooleanParam.new('p').validate_value(true, true))
    assert(!Poncho::Param::BooleanParam.new('p').validate_value(false, false))
    assert(!Poncho::Param::BooleanParam.new('p').validate_value(true, 'true'))
    assert(!Poncho::Param::BooleanParam.new('p').validate_value(false, 'false'))
    assert(!Poncho::Param::BooleanParam.new('p').validate_value(true, '1'))
    assert(!Poncho::Param::BooleanParam.new('p').validate_value(false, '0'))
    assert(!Poncho::Param::BooleanParam.new('p').validate_value(true, 1))
    assert(!Poncho::Param::BooleanParam.new('p').validate_value(false, 0))

    assert_equal(
      {:expected => 'boolean (true or false)', :actual => 'NilClass'},
      Poncho::Param::BooleanParam.new('p').validate_value(nil, nil)
      )

    assert_equal(
      {:expected => 'boolean (true or false)', :actual => 'abc'},
      Poncho::Param::BooleanParam.new('p').validate_value(nil, 'abc')
      )

    assert_equal(
      {:expected => 'boolean (true or false)', :actual => 'Float'},
      Poncho::Param::BooleanParam.new('p').validate_value(nil, 1.1)
      )
  end

  def test_boolean_param_convert
    p = Poncho::Param::BooleanParam.new('p')

    [true, 'true', '1', 1, 'yes'].each do |v|
      assert_equal(true, p.convert(v))
    end

    [false, 'false', '0', 0, 'no'].each do |v|
      assert_equal(false, p.convert(v))
    end

    [nil, 'abc', 1.1, [], 123, -1, 'y', 'n'].each do |v|
      assert_equal(nil, p.convert(v))
    end
  end

  def test_integer_param_validation
    assert(!Poncho::Param::IntegerParam.new('p').validate_value(1, '1'))
    assert(!Poncho::Param::IntegerParam.new('p').validate_value(0, 0))
    assert(!Poncho::Param::IntegerParam.new('p').validate_value(-100, -100))

    assert_equal(
      {:expected => 'integer', :actual => 'TrueClass'},
      Poncho::Param::IntegerParam.new('p').validate_value(nil, true)
      )

    assert_equal(
      {:expected => 'integer', :actual => 'abc'},
      Poncho::Param::IntegerParam.new('p').validate_value(nil, 'abc')
      )

    assert_equal(
      {:expected => 'integer', :actual => 'Float'},
      Poncho::Param::IntegerParam.new('p').validate_value(1.2, 1.2)
      )
  end

  def test_integer_param_convert
    p = Poncho::Param::IntegerParam.new('p')

    assert_equal(1, p.convert('1'))
    assert_equal(1, p.convert(1))

    [nil, 'abc', 1.2, true].each do |v|
      assert_equal(nil, p.convert(v))
    end
  end

  def test_float_param_validation
    assert(!Poncho::Param::FloatParam.new('p').validate_value(1.0, '1'))
    assert(!Poncho::Param::FloatParam.new('p').validate_value(1.2, 1.2))
    assert(!Poncho::Param::FloatParam.new('p').validate_value(-100.2, -100.2))
    assert(!Poncho::Param::FloatParam.new('p').validate_value(0.0, 0.0))

    assert_equal(
      {:expected => 'floating point number', :actual => 'abc'},
      Poncho::Param::FloatParam.new('p').validate_value(nil, 'abc')
      )

    assert_equal(
      {:expected => 'floating point number', :actual => 'TrueClass'},
      Poncho::Param::FloatParam.new('p').validate_value(nil, true)
      )

    assert_equal(
      {:expected => 'floating point number', :actual => 'Fixnum'},
      Poncho::Param::FloatParam.new('p').validate_value(0, 0)
      )
  end

  def test_float_param_convert
    p = Poncho::Param::FloatParam.new('p')

    assert_equal(1.1, p.convert('1.1'))
    assert_equal(1.0, p.convert('1'))
    assert_equal(1.2, p.convert(1.2))
    assert_equal(0, p.convert(0))

    [nil, 'abc', true].each do |v|
      assert_equal(nil, p.convert(v))
    end
  end
end

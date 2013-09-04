require File.expand_path(File.join(File.dirname(__FILE__), '../_lib'))

class TestParam < Test
  def test_array_param_validation
    errors = Poncho::Errors.new(nil)
    record = stub(:errors => errors)

    errors.expects(:add).never
    Poncho::Params::ArrayParam.new("array").validate_each(record, "foo", [])

    errors.expects(:add).with('foo', :expected => 'array', :actual => 'String')
    Poncho::Params::ArrayParam.new("array").validate_each(record, "foo", "bar")
  end

  def test_string_param_validation
    errors = Poncho::Errors.new(nil)
    record = stub(:errors => errors)

    errors.expects(:add).never
    Poncho::Params::StringParam.new("p").validate_each(record, "foo", "bar")

    errors.expects(:add).with('foo', :expected => 'string', :actual => 'NilClass')
    Poncho::Params::StringParam.new("p").validate_each(record, "foo", nil)
  end

  def test_boolean_param_validation
    errors = Poncho::Errors.new(nil)
    record = stub(:errors => errors)

    errors.expects(:add).never
    Poncho::Params::BooleanParam.new("p").validate_each(record, "foo", true)
    Poncho::Params::BooleanParam.new("p").validate_each(record, "foo", false)

    errors.expects(:add).with('foo', :expected => 'boolean (true or false)', :actual => 'NilClass')
    Poncho::Params::BooleanParam.new("p").validate_each(record, "foo", nil)
  end

  def test_integer_param_validation
    errors = Poncho::Errors.new(nil)
    record = stub(:errors => errors)

    errors.expects(:add).never
    Poncho::Params::IntegerParam.new("p").validate_each(record, "foo", 1)
    Poncho::Params::IntegerParam.new("p").validate_each(record, "foo", 0)
    Poncho::Params::IntegerParam.new("p").validate_each(record, "foo", -100)

    errors.expects(:add).with('foo', :expected => 'integer', :actual => 'abc')
    Poncho::Params::IntegerParam.new("p").validate_each(record, "foo", 'abc')

    errors.expects(:add).with('foo', :expected => 'integer', :actual => 'Float')
    Poncho::Params::IntegerParam.new("p").validate_each(record, "foo", 1.2)
  end

  def test_float_param_validation
    errors = Poncho::Errors.new(nil)
    record = stub(:errors => errors)

    errors.expects(:add).never
    Poncho::Params::FloatParam.new("p").validate_each(record, "foo", 1)
    Poncho::Params::FloatParam.new("p").validate_each(record, "foo", 1.2)
    Poncho::Params::FloatParam.new("p").validate_each(record, "foo", -100.2)
    Poncho::Params::FloatParam.new("p").validate_each(record, "foo", 0)

    errors.expects(:add).with('foo', :expected => 'floating point number', :actual => 'abc')
    Poncho::Params::FloatParam.new("p").validate_each(record, "foo", 'abc')

    errors.expects(:add).with('foo', :expected => 'floating point number', :actual => 'TrueClass')
    Poncho::Params::FloatParam.new("p").validate_each(record, "foo", true)
  end

  def test_integer_param_validation
    errors = Poncho::Errors.new(nil)
    record = stub(:errors => errors)

    errors.expects(:add).never
    Poncho::Params::IntegerParam.new("p").validate_each(record, "foo", 123)
    Poncho::Params::IntegerParam.new("p").validate_each(record, "foo", 0)
    Poncho::Params::IntegerParam.new("p").validate_each(record, "foo", -1)
    Poncho::Params::IntegerParam.new("p").validate_each(record, "foo", '-1')

    errors.expects(:add).with('foo', :expected => 'integer', :actual => 'TrueClass')
    Poncho::Params::IntegerParam.new("p").validate_each(record, "foo", true)

    errors.expects(:add).with('foo', :expected => 'integer', :actual => 'Float')
    Poncho::Params::IntegerParam.new("p").validate_each(record, "foo", 3.3)
  end

end

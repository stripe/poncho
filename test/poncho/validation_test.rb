require File.expand_path(File.join(File.dirname(__FILE__), '../_lib'))

class TestValidation < Test

  def test_format_options
    valid_args = {
      :attributes => [:baz],
      :message => 'foo',
      :with => /bar/
    }

    # Valid
    Poncho::Validation::FormatValidator.new(valid_args.dup)

    Poncho::Validation::FormatValidator.new(
      valid_args.reject{|k, v| k == :with}.merge(:without => /bar/))

    Poncho::Validation::FormatValidator.new(
      valid_args.merge(:with => lambda { false }))

    # Initialization
    assert_raises ArgumentError do
      Poncho::Validation::FormatValidator.new(valid_args.reject{|k, v| k == :attributes})
    end

    assert_raises ArgumentError do
      Poncho::Validation::FormatValidator.new(valid_args.merge(:attributes => []))
    end

    assert_raises ArgumentError do
      Poncho::Validation::FormatValidator.new(valid_args.merge(:attributes => 'baz'))
    end

    # Invalid other options
    assert_raises ArgumentError do
      Poncho::Validation::FormatValidator.new(valid_args.reject{|k, v| k == :with})
    end

    assert_raises ArgumentError do
      Poncho::Validation::FormatValidator.new(valid_args.merge(:without => /baz/))
    end

    assert_raises ArgumentError do
      Poncho::Validation::FormatValidator.new(valid_args.merge(:with => '/baz/'))
    end

    assert_raises ArgumentError do
      Poncho::Validation::FormatValidator.new(valid_args.reject{|k, v| k == :message})
    end
  end

  def test_format_validation
    errors = stub()
    record = stub(:errors => errors)

    errors.expects(:add).with(:baz, 'with message')
    with_validator = Poncho::Validation::FormatValidator.new(
      :attributes => [:baz], :message => 'with message', :with => /bar/)
    with_validator.validate_each(record, :baz, 'boo')

    errors.expects(:add).with(:baz, 'without message')
    without_validator = Poncho::Validation::FormatValidator.new(
      :attributes => [:baz], :message => 'without message', :without => /boo/)
    without_validator.validate_each(record, :baz, 'boo')

    # Valid
    with_validator.validate_each(record, :baz, 'Time to go to the bar.')
    without_validator.validate_each(record, :baz, 'Time to go to the bar.')
  end

  def test_exclusions_validation
    errors = stub()
    record = stub(:errors => errors)

    array_validator = Poncho::Validation::InclusionValidator.new(
      :not_in => [1, "a", false], :attributes => [:foo])
    lambda_validator = Poncho::Validation::InclusionValidator.new(
      :not_in => lambda{|x| [2, 'b', true]}, :attributes => [:foo])
    range_validator = Poncho::Validation::InclusionValidator.new(
      :not_in => 0..10, :attributes => [:foo])

    errors.expects(:add).with(:baz, regexp_matches(/'a'.*cannot.* 1, a, false\.\z/))
    errors.expects(:add).with(:baz, regexp_matches(/'false'.*cannot.* 1, a, false\.\z/))
    errors.expects(:add).with(:boz, regexp_matches(/'2'.*cannot.* 2, b, true\.\z/))
    errors.expects(:add).with(:boz, regexp_matches(/'true'.*cannot.* 2, b, true\.\z/))
    errors.expects(:add).with(:biz, regexp_matches(/'2'.*cannot.* 0 through 10\.\z/))

    # Invalid
    array_validator.validate_each(record, :baz, 'a')
    array_validator.validate_each(record, :baz, false)
    lambda_validator.validate_each(record, :boz, 2)
    lambda_validator.validate_each(record, :boz, true)
    range_validator.validate_each(record, :biz, 2)

    # Valid
    array_validator.validate_each(record, :baz, true)
    lambda_validator.validate_each(record, :boz, false)
    range_validator.validate_each(record, :biz, 11)
  end

  def test_inclusions_validation
    errors = stub()
    record = stub(:errors => errors)

    array_validator = Poncho::Validation::InclusionValidator.new(
      :in => [1, "a", false], :attributes => [:foo])
    lambda_validator = Poncho::Validation::InclusionValidator.new(
      :in => lambda{|x| [2, 'b', true]}, :attributes => [:foo])
    range_validator = Poncho::Validation::InclusionValidator.new(
      :in => 0..10, :attributes => [:foo])

    errors.expects(:add).with(:baz, regexp_matches(/'b'.*must.* 1, a, false\.\z/))
    errors.expects(:add).with(:baz, regexp_matches(/'true'.*must.* 1, a, false\.\z/))
    errors.expects(:add).with(:boz, regexp_matches(/'1'.*must.* 2, b, true\.\z/))
    errors.expects(:add).with(:boz, regexp_matches(/'false'.*must.* 2, b, true\.\z/))
    errors.expects(:add).with(:biz, regexp_matches(/'11'.*must.* 0 through 10\.\z/))

    # Invalid
    array_validator.validate_each(record, :baz, 'b')
    array_validator.validate_each(record, :baz, true)
    lambda_validator.validate_each(record, :boz, 1)
    lambda_validator.validate_each(record, :boz, false)
    range_validator.validate_each(record, :biz, 11)

    # Valid
    array_validator.validate_each(record, :baz, 'a')
    array_validator.validate_each(record, :baz, false)
    lambda_validator.validate_each(record, :boz, 2)
    lambda_validator.validate_each(record, :boz, true)
    range_validator.validate_each(record, :biz, 2)
  end
end

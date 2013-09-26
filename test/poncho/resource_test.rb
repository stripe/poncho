require File.expand_path(File.join(File.dirname(__FILE__), '../_lib'))

class TestResource < Test
  class Fuzzy
    def initialize(attrs = {})
      attrs.each do |key, value|
        self.class.send :attr_accessor, key
        self.send("#{key}=", value)
      end
    end
  end

  class DivisibleByThreeValidator < Poncho::EachValidator
    def validate_each(record, attribute, value)
      if value % 3 != 0
        record.errors.add(attribute, :expected => "integer divisible by 3", :actual => value)
      end
    end
  end

  def test_resource_params
    resource_class = Class.new(Poncho::Resource) do
      param :amount, :type => :integer
    end

    resource = resource_class.new(Fuzzy.new(:amount => 123)).clean!
    assert_equal({:amount => 123}, resource.to_hash)
    assert_equal(123, resource[:amount])
  end

  def test_resource_params_from_hash
    resource_class = Class.new(Poncho::Resource) do
      param :amount, :type => :integer
      param :key, :type => :string
    end

    resource = resource_class.new({:amount => 123, :key => 'foo'}).clean!

    assert_equal({:amount => 123, :key => 'foo'}, resource.describe)
    assert_equal('foo', resource[:key])
  end

  def test_resource_type_validation
    resource_class = Class.new(Poncho::Resource) do
      param :amount, :type => :integer, :optional => true
    end

    assert(resource_class.new({:amount => nil}).clean)
    assert(resource_class.new({:amount => 1}).clean)

    assert(!resource_class.new({:amount => 's'}).clean)
  end

  def test_resource_extra_validation
    resource_class = Class.new(Poncho::Resource)

    resource_class.param :amount, :type => :integer, :validate_with => DivisibleByThreeValidator

    assert(resource_class.new({:amount => 3}).clean)
    assert(resource_class.new({:amount => -36}).clean)
    assert(resource_class.new({:amount => 0}).clean)

    rsc = resource_class.new({:amount => 3.3})
    assert_raises(Poncho::ValidationError){rsc.clean!}

    rsc = resource_class.new({:amount => -100})
    assert_raises(Poncho::ValidationError){rsc.clean!}
  end

  def test_resource_conversion
    resource_class = Class.new(Poncho::Resource) do
      param :amount, :type => :integer

      def describe_amount(value)
        value * 10
      end
    end

    resource = resource_class.new(Fuzzy.new(:amount => 2)).clean!
    assert_equal 20, resource[:amount]
    assert_equal({:amount => 20}, resource.to_hash)
  end

  def test_sub_resources
    card_resource_class = Class.new(Poncho::Resource) do
      param :number

      def describe_number(value)
        value[-4..-1]
      end
    end

    resource_class = Class.new(Poncho::Resource) do
      param :card, :resource => card_resource_class
    end

    card   = Fuzzy.new(:number => '4242 4242 4242 4242')
    resource = resource_class.new(Fuzzy.new(:card => card)).clean!
    assert_equal({:card => {:number => '4242'}}.to_hash, resource.describe)
  end
end

require File.expand_path(File.join(File.dirname(__FILE__), '../_lib'))

module Poncho::InstanceValidations
  class DivisibleByThreeValidator < Poncho::EachValidator
    def validate_each(record, attribute, value)
      unless value % 3 === 0
        record.errors.add(attribute, :expected => "integer divisible by 3", :actual => value)
      end
    end
  end
end

class TestResource < Test
  class Fuzzy
    def initialize(attrs = {})
      attrs.each do |key, value|
        self.class.send :attr_accessor, key
        self.send("#{key}=", value)
      end
    end
  end

  def test_resource_params
    resource_class = Class.new(Poncho::Resource) do
      param :amount, :type => :integer
    end

    resource = resource_class.new(Fuzzy.new(:amount => 123))
    assert_equal({:amount => 123}, resource.to_hash)
    assert_equal(123, resource.amount)
  end

  def test_resource_params_from_hash
    resource_class = Class.new(Poncho::Resource) do
      param :amount, :type => :integer
      param :key, :type => :string
    end

    resource = resource_class.new({:amount => 123, :key => 'foo'})

    assert_equal({:amount => 123, :key => 'foo'}, resource.to_hash)
    assert_equal('foo', resource.key)
  end

  def test_resource_type_validation
    resource_class = Class.new(Poncho::Resource) do
      param :amount, :type => :integer
    end

    resource = resource_class.new({:amount => nil})
    assert(resource.valid?)

    resource = resource_class.new({:amount => 1})
    assert(resource.valid?)

    resource = resource_class.new({:amount => 's'})
    assert(!resource.valid?)
  end

  def test_resource_extra_validation
    resource_class = Class.new(Poncho::Resource)

    resource_class.param :amount, :type => :integer, :divisible_by_three => true

    assert(resource_class.new({:amount => 3}).valid?)
    assert(resource_class.new({:amount => -36}).valid?)
    assert(resource_class.new({:amount => 0}).valid?)

    assert(!resource_class.new({:amount => 3.3}).valid?)
    assert(!resource_class.new({:amount => -100}).valid?)
  end

  def test_resource_conversion
    resource_class = Class.new(Poncho::Resource) do
      param :amount, :type => :integer

      def amount
        super * 10
      end
    end

    resource = resource_class.new(Fuzzy.new(:amount => 2))
    assert_equal 20, resource.amount
    assert_equal({:amount => 20}, resource.to_hash)
  end

  def test_sub_resources
    card_resource_class = Class.new(Poncho::Resource) do
      param :number

      def number
        super[-4..-1]
      end
    end

    resource_class = Class.new(Poncho::Resource) do
      param :card, :resource => card_resource_class
    end

    card   = Fuzzy.new(:number => '4242 4242 4242 4242')
    resource = resource_class.new(Fuzzy.new(:card => card))
    assert_equal({:card => {:number => '4242'}}.to_json, resource.to_json)
  end
end

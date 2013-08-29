require 'minitest/autorun'
require 'rack/mock'
require 'poncho'
require 'json'

class TestResource < MiniTest::Unit::TestCase
  class Fuzzy
    def initialize(attrs = {})
      attrs.each do |key, value|
        self.class.send :attr_accessor, key
        self.send("#{key}=", value)
      end
    end
  end

  def test_resource_params
    resource = Class.new(Poncho::Resource) do
      param :amount, :type => :integer
    end

    result = resource.new(Fuzzy.new(:amount => 1))
    assert_equal({:amount => 1}, result.as_json)
  end

  def test_resource_validation
    resource = Class.new(Poncho::Resource) do
      param :amount, :type => :integer
    end

    result = resource.new(Fuzzy.new(:amount => nil))
    assert result.valid?

    result = resource.new(Fuzzy.new(:amount => 1))
    assert result.valid?

    result = resource.new(Fuzzy.new(:amount => 's'))
    assert !result.valid?
  end

  def test_resource_conversion
    resource = Class.new(Poncho::Resource) do
      param :amount, :type => :integer

      def amount
        super * 10
      end
    end

    result = resource.new(Fuzzy.new(:amount => 2))
    assert_equal 20, result.amount
    assert_equal({:amount => 20}, result.as_json)
  end

  def test_sub_resources
    card_resource = Class.new(Poncho::Resource) do
      param :number

      def number
        super[-4..-1]
      end
    end

    resource = Class.new(Poncho::Resource) do
      param :card, :resource => card_resource
    end

    card   = Fuzzy.new(:number => '4242 4242 4242 4242')
    result = resource.new(Fuzzy.new(:card => card))
    assert_equal({:card => {:number => '4242'}}.to_json, result.to_json)
  end
end
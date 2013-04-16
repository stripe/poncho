require 'minitest/autorun'
require 'rack/mock'
require 'poncho'

class TestJSONMethod < MiniTest::Unit::TestCase
  def env(params = {})
    Rack::MockRequest.env_for('http://api.com/charges', :params => params)
  end

  def setup
    @method = Class.new(Poncho::JSONMethod) do
      param :id, :type => :integer
      param :body, :type => :string

      def invoke
        params
      end
    end
  end

  def test_serializes_body
    status, headers, body = @method.call(env(:id => '1', :body => 'wem'))
    assert_equal({:id => 1, :body => 'wem'}.to_json, body.body.first)
  end

  def test_serializes_errors
    status, headers, body = @method.call(env(:id => 'string', :body => 'wem'))
    assert_equal({:error => {:param => 'id', :type => 'invalid_integer', :message => nil}}.to_json, body.body.first)
  end
end

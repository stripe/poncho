require File.expand_path(File.join(File.dirname(__FILE__), '../_lib'))

class TestJSONMethod < Test
  def env(params = {})
    Rack::MockRequest.env_for('http://api.com/charges', :params => params)
  end

  def setup
  end

  def test_serializes_body
     method = Class.new(Poncho::JSONMethod) do
      param :id, :type => :integer
      param :body, :type => :string

      def invoke
        params
      end
    end

    status, headers, body = method.call(env(:id => '1', :body => 'wem'))
    assert_equal({:id => 1, :body => 'wem'}.to_json, body.body.first)
  end

  def test_serializes_errors
     method = Class.new(Poncho::JSONMethod) do
      param :id, :type => :integer
      param :body, :type => :string

      def invoke
        params
      end
    end

    status, headers, body = method.call(env(:id => 'string', :body => 'wem'))

    assert_equal(422, status, "Expected 422 but got #{status} with body: #{body.body.first}")

    res = JSON.parse(body.body.first)

    assert_equal('id', res['error']['param'])
    assert_equal('validation_error', res['error']['type'])
    assert_match(/valid integer/, res['error']['message'])
  end
end

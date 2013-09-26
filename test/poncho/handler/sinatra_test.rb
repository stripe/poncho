ENV['RACK_ENV'] = 'test'

require File.expand_path(File.join(File.dirname(__FILE__), '../../_lib'))

require 'json'
require 'sinatra/base'
require 'rack/test'
require 'poncho/handler/sinatra'
require 'poncho/serializer/json'

class TestResource < Test
  include Rack::Test::Methods

  class TestMethod < Poncho::Method
    accepts do
      param :id
      param :count, :type => :integer, :optional => true
    end

    returns do
      param :foo_id, :attribute => :id
      param :count, :type => :integer, :optional => true
    end

    def invoke(rsc)
      return rsc
    end

    error Poncho::Error do
      if @poncho_error.code >= 500
        p @poncho_error.to_s
      end
      Poncho::ErrorResource.new(@poncho_error).clean!
    end
  end

  class ErrorTestMethod < Poncho::Method
    accepts do
      param :error_type, :in => ['rsc_validation', 'server']
    end

    returns do
      param :id
      param :foo, :type => :integer
    end

    def invoke(rsc)
      case rsc[:error_type]
      when 'rsc_validation'
        {:foo => 'bar'}
      when 'server'
        raise Poncho::ServerError.new('fake error')
      else
        { :id => 'bar', :foo => 2}
      end
    end
  end

  class TestApp < Sinatra::Base
    register Poncho::Handler::Sinatra

    poncho Poncho::Serializer::JSON do
      get '/foo/:id', TestMethod
      post '/foo', TestMethod

      put '/err', ErrorTestMethod
    end
  end

  def app
    TestApp
  end

  def verifying_status(status)
    yield
    response = last_response()
    assert_equal(status, response.status)

    JSON.parse(response.body)
  end

  def test_get_with_path_parameter
    res = verifying_status(200){get '/foo/bar'}

    assert_equal(2, res.keys.count)
    assert_equal('bar', res['foo_id'])
    assert_equal(nil, res['count'])
  end

  def test_get_with_query_parameter
    res = verifying_status(200){get '/foo/bar?count=5'}

    assert_equal(2, res.keys.count)
    assert_equal('bar', res['foo_id'])
    assert_equal(5, res['count'])
  end

  def test_post
    res = verifying_status(200){post '/foo', :id => 'bar'}

    assert_equal(2, res.keys.count)
    assert_equal('bar', res['foo_id'])
    assert_equal(nil, res['count'])
  end

  def test_serializes_validation_errors
    res = verifying_status(422){ put '/err', :error_type => 'boo' }
    err = res['error']

    assert_equal(3, err.keys.count)
    assert_equal('validation_error', err['type'])
    assert_match(/error_type is invalid/, err['message'])
  end

  def test_serializes_extra_param_error
    res = verifying_status(400){ put '/err', :error_type => 'boo', :foo => 'bar' }
    err = res['error']

    assert_equal(3, err.keys.count)
    assert_equal('client_error', err['type'])
    assert_match(/do not include any of 'foo'/, err['message'])
  end

  def test_serializes_resource_validation_errors
    res = verifying_status(500){ put '/err', :error_type => 'rsc_validation'}
    err = res['error']

    assert_equal(3, err.keys.count)
    assert_equal('server_error', err['type'])
    assert_match(/something went wrong/, err['message'])
  end

  def test_serializes_server_error
    res = verifying_status(500){ put '/err', :error_type => 'server'}
    err = res['error']

    assert_equal(3, err.keys.count)
    assert_equal('server_error', err['type'])
    assert_match(/something went wrong/, err['message'])
  end
end

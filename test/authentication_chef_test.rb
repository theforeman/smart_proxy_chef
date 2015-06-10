require 'test_helper'
require 'webmock/test_unit'
require 'smart_proxy_chef_plugin/chef_plugin'
require 'smart_proxy_chef_plugin/authentication'
require 'net/https'

class AuthenticationChefTest < Test::Unit::TestCase
  class Dummy
    include ChefPlugin::ConnectionHelper
    include ChefPlugin::Authentication::InstanceMethods

    def logger
      @logger ||= Logger.new(StringIO.new)
    end

    def log_halt(*args)
      throw :halt
    end
  end

  def setup
    ::ChefPlugin::Plugin.settings.stubs(:chef_server_url).returns('https://chef.example.com')
    ::ChefPlugin::Plugin.settings.stubs(:chef_smartproxy_clientname).returns('testnode1')
    ::ChefPlugin::Plugin.settings.stubs(:chef_smartproxy_privatekey).returns('test/fixtures/authentication/testnode1.priv')

    testnode1_key_path = 'test/fixtures/authentication/testnode1'
    testnode2_key_path = 'test/fixtures/authentication/testnode2'
    testnode1_key = OpenSSL::PKey::RSA.new(File.read(testnode1_key_path+'.priv'))
    @testnode1_pubkey = testnode1_key.public_key.to_s.gsub("\n",'\n')
    testnode2_key = OpenSSL::PKey::RSA.new(File.read(testnode2_key_path+'.priv'))
    @testnode2_pubkey = testnode2_key.public_key.to_s.gsub("\n",'\n')

    #we sign with the testnode1 key
    @mybody = "ForemanRoxx"
    hash_body = Digest::SHA256.hexdigest(@mybody)
    @signature = Base64.encode64(testnode1_key.sign(OpenSSL::Digest::SHA256.new,hash_body)).gsub("\n",'')
  end

  test 'signing_and_checking_with_same_key_sould_work' do
    chefauth = Dummy.new
    # We need to mock chef-server response
    response = '{"public_key":"'+@testnode1_pubkey+'","name":"testnode1","admin":false,"validator":false,"json_class":"Chef::ApiClient","chef_type":"client"}'
    stub_request(:get, "https://chef.example.com/clients/testnode1").
        to_return(:body => response.to_s, :headers => {'content-type' => 'application/json'} )

    chefauth.expects(:log_halt).never
    assert(chefauth.verify_signature_request('testnode1', @signature, @mybody), "Signing and checking with same key should pass")
  end

  test 'signing_and_checking_with_2_different_keys_sould_not_work' do
    chefauth = Dummy.new
    # We mock chef-server response but with a wrong publick key to make signature check fail
    response = '{"public_key":"'+@testnode2_pubkey+'","name":"testnode1","admin":false,"validator":false,"json_class":"Chef::ApiClient","chef_type":"client"}'
    stub_request(:get, "https://chef.example.com/clients/testnode1").
        to_return(:body => response.to_s, :headers => {'content-type' => 'application/json'} )

    refute(chefauth.verify_signature_request('testnode1', @signature, @mybody), "Signing and checking with different keys should not pass")
  end

  test 'auth_disabled_should_always_succeed' do
    chefauth = Dummy.new
    ChefPlugin::Plugin.settings.stubs(:chef_authenticate_nodes).returns(false)
    s = StringIO.new('Hello')
    request = Sinatra::Request.new(env={'rack.input' => s})
    assert chefauth.authenticate_chef_signature(request)
  end

  test 'auth_enable_without_headers_should_raise_an_error' do
    chefauth = Dummy.new
    ChefPlugin::Plugin.settings.stubs(:chef_authenticate_nodes).returns(true)
    s = StringIO.new('Hello')
    request = Sinatra::Request.new(env={'rack.input' => s})
    assert_throws :halt do
      refute chefauth.authenticate_chef_signature(request)
    end
  end
end

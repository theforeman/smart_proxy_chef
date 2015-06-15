require 'test_helper'
require 'smart_proxy_chef_plugin/request'
require 'webmock/test_unit'

class ProxyRequestTest < Test::Unit::TestCase
  def setup
    @foreman_url = 'https://foreman.example.com'
    Proxy::SETTINGS.stubs(:foreman_url).returns(@foreman_url)
  end

  def test_post_facts
    facts = {'fact' => "sample"}
    stub_request(:post, @foreman_url+'/api/hosts/facts')
    result = ChefPlugin::HttpRequest::Facts.new.post_facts(facts)

    assert(result.is_a? Net::HTTPOK)
  end

  def test_post_reports
    report = {'report' => "sample"}
    stub_request(:post, @foreman_url+'/api/reports')
    result = ChefPlugin::HttpRequest::Reports.new.post_report(report)

    assert(result.is_a? Net::HTTPOK)
  end
end

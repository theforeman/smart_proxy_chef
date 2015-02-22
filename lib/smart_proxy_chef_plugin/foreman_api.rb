require 'proxy/request'
require 'smart_proxy_chef_plugin/authentication'

module ChefPlugin
  class ForemanApi < ::Sinatra::Base
    helpers ::Proxy::Helpers
    authorize_with_trusted_hosts
    authorize_with_ssl_client

    error Proxy::Error::BadRequest do
      log_halt(400, "Bad request : " + env['sinatra.error'].message )
    end

    error Proxy::Error::Unauthorized do
      log_halt(401, "Unauthorized : " + env['sinatra.error'].message )
    end

    post "/hosts/facts" do
      logger.debug 'facts upload request received'
      ChefPlugin::Authentication.new.authenticated(request) do |content|
        Proxy::HttpRequest::Facts.new.post_facts(content)
      end
    end

    post "/reports" do
      logger.debug 'report upload request received'
      ChefPlugin::Authentication.new.authenticated(request) do |content|
        Proxy::HttpRequest::Reports.new.post_report(content)
      end
    end
  end
end

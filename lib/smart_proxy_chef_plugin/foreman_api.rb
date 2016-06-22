require 'proxy/request'
require 'smart_proxy_chef_plugin/request'
require 'smart_proxy_chef_plugin/authentication'

module ChefPlugin
  ::Sinatra::Base.register Authentication

  class ForemanApi < ::Sinatra::Base
    class BadRequest < StandardError; end
    class Unauthorized < StandardError; end

    helpers ::Proxy::Helpers
    authenticate_with_chef_signature

    error BadRequest do
      log_halt(400, "Bad request: " + env['sinatra.error'].message )
    end

    error Unauthorized do
      log_halt(401, "Unauthorized: " + env['sinatra.error'].message )
    end

    post "/hosts/facts" do
      logger.debug 'facts upload request received'
      foreman_response = ChefPlugin::HttpRequest::Facts.new.post_facts(get_content)
      log_result(foreman_response)
    end

    post "/reports" do
      logger.debug 'report upload request received'
      foreman_response = ChefPlugin::HttpRequest::Reports.new.post_report(get_content)
      log_result(foreman_response)
    end

    private

    def get_content
      input = request.env['rack.input']
      input.rewind
      input.read
    end

    def log_result(foreman_response)
      code = foreman_response.code.to_i
      if code >= 200 && code < 300
        logger.debug "upload forwarded to Foreman successfully, response was #{code}"
      else
        logger.error "forwarding failed, Foreman responded with #{code}, check Foreman access and production logs for more details"
      end
    end
  end
end

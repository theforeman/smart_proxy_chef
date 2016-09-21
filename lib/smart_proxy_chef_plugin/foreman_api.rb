require 'proxy/request'
require 'smart_proxy_chef_plugin/request'
require 'smart_proxy_chef_plugin/authentication'
require 'uri'
require 'yaml'

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

    get '/enc/:client' do |client|
      begin
        if client != request.env['HTTP_X_FOREMAN_CLIENT']
          log_halt(401, "Unauthorized : client '#{request.env['HTTP_X_FOREMAN_CLIENT']}' is asking for other client '#{client}' data")
        end
        content_type :json
        result = ChefPlugin::HttpRequest::Hosts.new.host_enc(client)
        log_result(result)
        log_halt(500, "Could not fetch ENC for #{client}, see Foreman production.log for more details") unless result.code.to_s.start_with?('2')

        yaml_enc = result.body
        YAML.load(yaml_enc).to_json
      rescue => e
        log_halt 400, e
      end
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

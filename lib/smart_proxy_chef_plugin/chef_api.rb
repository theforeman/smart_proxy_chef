require 'proxy/request'
require 'smart_proxy_chef_plugin/authentication'
require 'smart_proxy_chef_plugin/resources/node'
require 'smart_proxy_chef_plugin/resources/client'

module ChefPlugin
  class ForemanApi < ::Sinatra::Base
    helpers ::Proxy::Helpers
    authorize_with_trusted_hosts

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

  class ChefApi < ::Sinatra::Base
    get "/nodes/:fqdn" do
      logger.debug "Showing node #{params[:fqdn]}"

      content_type :json
      if (node = Resources::Node.new.show(params[:fqdn]))
        node.to_json
      else
        log_halt 404, "Node #{params[:fqdn]} not found"
      end
    end

    get "/clients/:fqdn" do
      logger.debug "Showing client #{params[:fqdn]}"

      content_type :json
      if (node = Resources::Client.new.show(params[:fqdn]))
        node.to_json
      else
        log_halt 404, "Client #{params[:fqdn]} not found"
      end
    end

    delete "/chef/nodes/:fqdn" do
      logger.debug "Starting deletion of node #{params[:fqdn]}"

      result = Resources::Node.new.delete(params[:fqdn])
      log_halt 400, "Node #{params[:fqdn]} could not be deleteded" unless result

      logger.debug "Node #{params[:fqdn]} deleted"
      { :result => result }.to_json
    end

    delete "/chef/clients/:fqdn" do
      logger.debug "Starting deletion of client #{params[:fqdn]}"

      result = Resources::Client.new.delete(params[:fqdn])
      log_halt 400, "Client #{params[:fqdn]} could not be deleted" unless result

      logger.debug "Client #{params[:fqdn]} deleted"
      { :result => result }.to_json
    end
  end
end

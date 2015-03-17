require 'smart_proxy_chef_plugin/connection_helper'
require 'smart_proxy_chef_plugin/chef_resource_api'

module ChefPlugin
  class ChefApi < ::Sinatra::Base
    helpers ::Proxy::Helpers, ConnectionHelper
    extend ChefResourceApi
    authorize_with_trusted_hosts

    before do
      content_type :json
      @connection = get_connection
    end

    error ChefAPI::Error::UnknownAttribute do
      log_halt 400, {:result => false, :errors => [env['sinatra.error'].message]}.to_json
    end

    error ChefAPI::Error::ResourceNotFound do
      log_halt 404, {:result => false, :errors => [env['sinatra.error'].message]}.to_json
    end

    resource :client
    put "/clients/:id/regenerate_keys" do
      logger.debug "Regenerating client #{params[:id]} keys"
      client = @connection.clients.fetch(params[:id])
      log_halt 404, "Client #{params[:id]} not found" if client.nil?

      if client.regenerate_keys
        logger.debug "Client #{params[:id]} keys regenerated"
        client.to_json
      else
        log_halt 400, { :errors => 'Unable to regenerate keys' }.to_json
      end
    end

    # commented resources do not work since they are scoped under other resource are not standard in other way
    # resource :collection_proxy, :plural_name => 'collection_proxies'
    resource :cookbook
    # resource :cookbook_version
    resource :data_bag
    # resource :data_bag_item
    resource :environment
    resource :node
    # resource :organization
    # resource :partial_search, :plural_name => 'partial_searches'
    # resource :principal
    resource :role
    # resource :search, :plural_name => 'searches'
    resource :user
  end
end

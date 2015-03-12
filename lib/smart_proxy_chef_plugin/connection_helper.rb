require 'chef-api'

module ChefPlugin
  module ConnectionHelper
    def get_connection
      connection = ::ChefAPI::Connection.new(
        :endpoint => ChefPlugin::Plugin.settings.chef_server_url,
        :client => ChefPlugin::Plugin.settings.chef_smartproxy_clientname,
        :key => ChefPlugin::Plugin.settings.chef_smartproxy_privatekey,
      )
      connection.ssl_verify = ChefPlugin::Plugin.settings.chef_ssl_verify
      self_signed = ChefPlugin::Plugin.settings.chef_ssl_pem_file
      if !self_signed.nil? && !self_signed.empty?
        connection.ssl_pem_file = self_signed
      end

      connection
    end
  end
end

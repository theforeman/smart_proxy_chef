require 'smart_proxy_chef_plugin/resources/base'

module ChefPlugin::Resources
  class Node < Base
    def initialize
      super
      @base = @connection.nodes
    end

    def delete(fqdn)
      @base.delete(fqdn)
    end

    def show(fqdn)
      @base.fetch(fqdn)
    end
  end
end

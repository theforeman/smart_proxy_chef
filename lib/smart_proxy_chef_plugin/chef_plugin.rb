module ChefPlugin
  class Plugin < Proxy::Plugin
    http_rackup_path File.expand_path("http_config.ru", File.expand_path("../", __FILE__))
    https_rackup_path File.expand_path("http_config.ru", File.expand_path("../", __FILE__))
  
    settings_file "chef.yml"
    default_settings :chef_authenticate_nodes => true,
                     :chef_smartproxy_privatekey => '/etc/chef/client.pem',
                     :chef_ssl_verify => true,
                     :chef_ssl_pem_file => nil
    plugin :chef, ChefPlugin::VERSION
  end
end

require 'smart_proxy_chef_plugin/foreman_api'
require 'smart_proxy_chef_plugin/chef_api'

map "/api" do
  run ChefPlugin::ForemanApi
end

map "/chef" do
  run ChefPlugin::ChefApi
end

require 'smart_proxy_chef_plugin/connection_helper'
require 'digest/sha2'
require 'base64'
require 'openssl'

module ChefPlugin
  module Authentication
    def authenticate_with_chef_signature
      helpers ConnectionHelper, InstanceMethods, ::Proxy::Helpers

      before do
        authenticate_chef_signature(request)
      end
    end

    module InstanceMethods
      def verify_signature_request(client_name, signature,body)
        #We need to retrieve client public key to verify signature
        begin
          client = get_connection.clients.fetch(client_name)
        rescue StandardError => e
          log_halt 401, "Failed to authenticate node: " + e.message + "\n#{e.backtrace.join("\n")}"
        end

        log_halt 401, "Could not find client with name #{client_name}" if client.nil?
        public_key = OpenSSL::PKey::RSA.new(client.public_key)

        #signature is base64 encoded
        decoded_signature = Base64.decode64(signature)
        hash_body = Digest::SHA256.hexdigest(body)
        public_key.verify(OpenSSL::Digest::SHA256.new, decoded_signature, hash_body)
      end

      def authenticate_chef_signature(request)
        logger.debug('starting chef signature authentication')
        content     = request.env["rack.input"].read

        auth = true
        if ChefPlugin::Plugin.settings.chef_authenticate_nodes
          client_name = request.env['HTTP_X_FOREMAN_CLIENT']
          logger.debug("header HTTP_X_FOREMAN_CLIENT: #{client_name}")
          signature   = request.env['HTTP_X_FOREMAN_SIGNATURE']

          log_halt 401, "Failed to authenticate node #{client_name}. Missing some headers" if client_name.nil? or signature.nil?
          auth = verify_signature_request(client_name, signature, content)
        end

        if auth
          log_halt 406, "Body is empty for node #{client_name}" if content.nil?
          logger.debug("#{client_name} authenticated successfully")
          return true
        else
          log_halt 401, "Failed to authenticate node #{client_name}"
        end
      end
    end
  end
end

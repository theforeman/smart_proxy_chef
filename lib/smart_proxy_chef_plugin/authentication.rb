require 'smart_proxy_chef_plugin/connection_helper'
require 'digest/sha2'
require 'base64'
require 'openssl'

module ChefPlugin
  class Authentication
    include ConnectionHelper

    def verify_signature_request(client_name, signature,body)
      #We need to retrieve client public key to verify signature
      begin
        client = get_connection.clients.fetch(client_name)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
        Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
        Errno::ECONNREFUSED, OpenSSL::SSL::SSLError => e
        raise Proxy::Error::Unauthorized, "Failed to authenticate node: "+e.message
      end

      raise Proxy::Error::Unauthorized, "Could not find client with name #{client_name}" if client.nil?
      public_key = OpenSSL::PKey::RSA.new(client.public_key)

      #signature is base64 encoded
      decoded_signature = Base64.decode64(signature)
      hash_body = Digest::SHA256.hexdigest(body)
      public_key.verify(OpenSSL::Digest::SHA256.new, decoded_signature, hash_body)
    end

    def authenticated(request, &block)
      content     = request.env["rack.input"].read

      auth = true
      if ChefPlugin::Plugin.settings.chef_authenticate_nodes
        client_name = request.env['HTTP_X_FOREMAN_CLIENT']
        signature   = request.env['HTTP_X_FOREMAN_SIGNATURE']

        raise Proxy::Error::Unauthorized, "Failed to authenticate node #{client_name}. Missing some headers" if client_name.nil? or signature.nil?
        auth = verify_signature_request(client_name, signature, content)
      end

      if auth
        raise Proxy::Error::BadRequest, "Body is empty for node #{client_name}" if content.nil?
        block.call(content)
      else
        raise Proxy::Error::Unauthorized, "Failed to authenticate node #{client_name}"
      end
    end
  end
end

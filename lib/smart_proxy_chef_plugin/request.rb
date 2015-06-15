require 'proxy/request'

module ChefPlugin
  module HttpRequest
    class Facts < ::Proxy::HttpRequest::ForemanRequest
      def post_facts(facts)
        send_request(request_factory.create_post('api/hosts/facts', facts))
      end
    end

    class Reports < ::Proxy::HttpRequest::ForemanRequest
      def post_report(report)
        send_request(request_factory.create_post('api/reports', report))
      end
    end
  end
end

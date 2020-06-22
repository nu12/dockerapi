require "excon"
require "singleton"
require "json"
module Docker
    module API
        class Connection
            include Singleton

            [:get, :post, :head, :delete, :put].each do | method |
                define_method(method) { | path | self.request(method: method, path: path) }
            end

            def post(path, body = nil)
                self.request(method: :post, path: path, headers: { "Content-Type" => "application/json" }, body: body.to_json)
            end

            def request params
                @connection.request(params)
            end
            
            private
            def initialize
                @connection = Excon.new('unix:///', :socket => '/var/run/docker.sock')
            end

        end
    end
end
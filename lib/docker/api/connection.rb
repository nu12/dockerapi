require "excon"
require "singleton"
require "json"
module Docker
    module API
        class Connection
            include Singleton

            attr_reader(:connection)

            def get path
                r = @connection.get(path: path)
                #p r
                r
            end

            def post(path, body = nil)
                if body
                    r = @connection.post(path: path, headers: { "Content-Type" => "application/json" }, body: body.to_json)
                else
                    r = @connection.post(path: path)
                end
                #p r
                r
            end

            def head(path)
                @connection.head(path: path)
            end

            def delete path
                @connection.delete(path: path)
            end
            
            private
            def initialize
                @connection = Excon.new('unix:///', :socket => '/var/run/docker.sock')
            end

        end
    end
end
require "json"
module Docker
    module API
        class System < Docker::API::Base

            def initialize connection = nil
                @connection = connection || Docker::API::Connection.new
            end
            
            def auth body = {}
                validate Docker::API::InvalidRequestBody, [:username, :password, :email, :serveraddress, :identitytoken], body
                @connection.request(method: :post, path: "/auth", headers: { "Content-Type" => "application/json" }, body: body.to_json)
            end

            def events params = {}
                validate Docker::API::InvalidParameter, [:since, :until, :filters], params
                @connection.request(method: :get, path: build_path("/events", params), response_block: lambda { |chunk, remaining_bytes, total_bytes| puts chunk.inspect } )
            end

            def ping
                @connection.get("/_ping")
            end

            def info
                @connection.get("/info")
            end

            def version
                @connection.get("/version")
            end

            def df
                @connection.get("/system/df")
            end
                        
        end
    end
end
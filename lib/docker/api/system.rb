require "json"
module Docker
    module API
        class System < Docker::API::Base
            
            def self.auth body = {}
                validate Docker::API::InvalidRequestBody, [:username, :password, :email, :serveraddress, :identitytoken], body
                connection.request(method: :post, path: "/auth", headers: { "Content-Type" => "application/json" }, body: body.to_json)
            end

            def self.events params = {}
                validate Docker::API::InvalidParameter, [:since, :until, :filters], params
                connection.request(method: :get, path: build_path("/events", params), response_block: lambda { |chunk, remaining_bytes, total_bytes| puts chunk.inspect } )
            end

            def self.ping
                connection.get("/_ping")
            end

            def self.info
                connection.get("/info")
            end

            def self.version
                connection.get("/version")
            end

            def self.df
                connection.get("/system/df")
            end
        end
    end
end
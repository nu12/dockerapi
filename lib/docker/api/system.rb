require "json"
module Docker
    module API
        class System < Docker::API::Base
            
            def self.auth body = {}
                validate Docker::API::InvalidRequestBody, [:username, :password, :email, :serveraddress, :identitytoken], body
                connection.request(method: :post, path: "/auth", headers: { "Content-Type" => "application/json" }, body: body.to_json)
            end

            def self.ping
                connection.get("/_ping")
            end
        end
    end
end
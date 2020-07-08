module Docker
    module API        
        class Node < Docker::API::Base
            
            def list params = {}
                validate Docker::API::InvalidParameter, [:filters], params
                @connection.get(build_path("/nodes", params))
            end

            def inspect name
                @connection.get("/nodes/#{name}")
            end

            def update name, params = {}, body = {}
                validate Docker::API::InvalidParameter, [:version], params
                validate Docker::API::InvalidRequestBody, [:Name, :Labels, :Role, :Availability], body
                @connection.request(method: :post, path: build_path("nodes/#{name}/update", params), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def delete name, params = {}
                validate Docker::API::InvalidParameter, [:force], params
                @connection.delete(build_path("/nodes/#{name}", params))
            end
        end
    end
end
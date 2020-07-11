module Docker
    module API        
        class Node < Docker::API::Base

            #################################################
            # Items in this area to be removed before 1.0.0 #
            #################################################
            def inspect *args
                return super.inspect if args.size == 0
                warn  "WARNING: #inspect is deprecated and will be removed in the future, please use #details instead."
                name = args[0]
                details(name)
            end
            #################################################
            
            def list params = {}
                validate Docker::API::InvalidParameter, [:filters], params
                @connection.get(build_path("/nodes", params))
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

            def details name
                @connection.get("/nodes/#{name}")
            end

        end
    end
end
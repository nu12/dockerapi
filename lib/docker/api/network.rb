module Docker
    module API        
        class Network < Docker::API::Base

            def list params = {}
                @connection.get(build_path("/networks", params))
            end

            def details name, params = {}
                @connection.get(build_path([name], params))
            end

            def create body = {}
                @connection.request(method: :post, path: build_path(["create"]), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def remove name
                @connection.delete(build_path([name]))
            end

            def prune params = {}
                @connection.post(build_path(["prune"], params))
            end

            def connect name, body = {}
                @connection.request(method: :post, path: build_path([name, "connect"]), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def disconnect name, body = {}
                @connection.request(method: :post, path: build_path([name, "disconnect"]), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            #################################################
            # Items in this area to be removed before 1.0.0 #
            #################################################
            def base_path
                "/networks"
            end

            def inspect *args
                return super.inspect if args.size == 0
                warn  "WARNING: #inspect is deprecated and will be removed in the future, please use #details instead."
                name, params = args[0], args[1] || {}
                details(name, params)
            end
            #################################################

        end
    end
end
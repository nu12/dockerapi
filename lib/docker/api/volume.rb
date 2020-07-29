module Docker
    module API
        class Volume < Docker::API::Base

            def list params = {}
                @connection.get(build_path("/volumes", params))
            end

            def details name
                @connection.get(build_path([name]))
            end

            def create body = {}
                @connection.request(method: :post, path: build_path(["create"]), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def remove name, params = {}
                @connection.delete(build_path([name]))
            end

            def prune params = {}
                @connection.post(build_path(["prune"], params))
            end

            #################################################
            # Items in this area to be removed before 1.0.0 #
            #################################################
            def base_path
                "/volumes"
            end

            def inspect *args
                return super.inspect if args.size == 0
                warn  "WARNING: #inspect is deprecated and will be removed in the future, please use #details instead."
                name = args[0]
                @connection.get(build_path([name]))
            end
            #################################################

        end
    end
end
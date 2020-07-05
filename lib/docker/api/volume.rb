module Docker
    module API
        class Volume < Docker::API::Base
            def base_path
                "/volumes"
            end

            def list params = {}
                validate Docker::API::InvalidParameter, [:filters], params
                @connection.get(build_path("/volumes", params))
            end

            def create body = {}
                validate Docker::API::InvalidRequestBody, [:Name, :Driver, :DriverOpts, :Labels], body
                @connection.request(method: :post, path: build_path(["create"]), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def inspect name
                @connection.get(build_path([name]))
            end

            def remove name, params = {}
                validate Docker::API::InvalidParameter, [:force], params
                @connection.delete(build_path([name]))
            end

            def prune params = {}
                validate Docker::API::InvalidParameter, [:filters], params
                @connection.post(build_path(["prune"], params))
            end

        end
    end
end
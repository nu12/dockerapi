module Docker
    module API
        class Service < Docker::API::Base

            def list params = {}
                validate Docker::API::InvalidParameter, [:filters], params
                @connection.get(build_path("/services", params))
            end

            def create body = {}, authentication = {}
                validate Docker::API::InvalidRequestBody, [:Name, :Labels, :TaskTemplate, :Mode, :UpdateConfig, :RollbackConfig, :Networks, :EndpointSpec], body
                headers = {"Content-Type": "application/json"}
                headers.merge!({"X-Registry-Auth" => Base64.urlsafe_encode64(authentication.to_json.to_s)}) if authentication.keys.size > 0
                @connection.request(method: :post, path: "/services/create", headers: headers, body: body.to_json)
            end

            def update name, params = {}, body = {}, authentication = {}
                # view https://github.com/docker/swarmkit/issues/1394#issuecomment-240850719
                validate Docker::API::InvalidParameter, [:version, :registryAuthFrom, :rollback], params
                validate Docker::API::InvalidRequestBody, [:Name, :Labels, :TaskTemplate, :Mode, :UpdateConfig, :RollbackConfig, :Networks, :EndpointSpec], body
                headers = {"Content-Type": "application/json"}
                headers.merge!({"X-Registry-Auth" => Base64.urlsafe_encode64(authentication.to_json.to_s)}) if authentication.keys.size > 0
                @connection.request(method: :post, path: build_path("/services/#{name}/update", params), headers: headers, body: body.to_json)
            end

            def details name, params = {}
                validate Docker::API::InvalidParameter, [:insertDefaults], params
                @connection.get(build_path("/services/#{name}", params))
            end

            def logs name, params = {}
                validate Docker::API::InvalidParameter, [:details, :follow, :stdout, :stderr, :since, :timestamps, :tail], params
                @connection.get(build_path("/services/#{name}/logs", params))
            end

            def delete name
                @connection.delete("/services/#{name}")
            end

        end
    end
end
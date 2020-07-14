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

            def details name, params = {}
                validate Docker::API::InvalidParameter, [:insertDefaults], params
                @connection.get(build_path("/services/#{name}", params))
            end

        end
    end
end
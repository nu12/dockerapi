# This class represents the Docker API endpoints regarding services.
#
# @see https://docs.docker.com/engine/api/v1.40/#tag/Service
#
# Services are the definitions of tasks to run on a swarm. Swarm mode must be enabled for these endpoints to work.
class Docker::API::Service < Docker::API::Base

    # List services
    #
    # Docker API: GET /services
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ServiceList
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def list params = {}
        @connection.get(build_path("/services", params))
    end

    # Create a service
    #
    # Docker API: POST /services/create
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ServiceCreate
    #
    # @param body [Hash]: Request body to be sent as json.
    #
    # @param authentication [Hash]: Authentication parameters.
    def create body = {}, authentication = {}
        headers = {"Content-Type": "application/json"}
        headers.merge!({"X-Registry-Auth" => Base64.urlsafe_encode64(authentication.to_json.to_s)}) if authentication.keys.size > 0
        @connection.request(method: :post, path: "/services/create", headers: headers, body: body.to_json)
    end

    # Update a service
    #
    # Docker API: POST /services/{id}/update
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ServiceUpdate
    #
    # @param name [String]: The ID or name of the service.
    #
    # @param params [Hash]:  Parameters that are appended to the URL.
    #
    # @param body [Hash]: Request body to be sent as json.
    #
    # @param authentication [Hash]:  Authentication parameters.
    def update name, params = {}, body = {}, authentication = {}
        # view https://github.com/docker/swarmkit/issues/1394#issuecomment-240850719
        headers = {"Content-Type": "application/json"}
        headers.merge!({"X-Registry-Auth" => Base64.urlsafe_encode64(authentication.to_json.to_s)}) if authentication.keys.size > 0
        @connection.request(method: :post, path: build_path("/services/#{name}/update", params), headers: headers, body: body.to_json)
    end

    # Inspect a service
    #
    # Docker API: GET /services/{id}
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ServiceInspect
    #
    # @param name [String]: The ID or name of the service.
    #
    # @param params [Hash]: Parameters that are appended to the URL. 
    def details name, params = {}
        @connection.get(build_path("/services/#{name}", params))
    end

    # Get stdout and stderr logs from a service. 
    #
    # Note: This endpoint works only for services with the local, json-file or journald logging drivers.
    #
    # Docker API: GET /services/{id}/logs
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ServiceLogs
    #
    # @param name [String]: The ID or name of the service.
    #
    # @param params [Hash]: Parameters that are appended to the URL. 
    def logs name, params = {}
        @connection.get(build_path("/services/#{name}/logs", params))
    end

    # Delete a service
    #
    # Docker API: DELETE /services/{id}
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ServiceDelete
    #
    # @param name [String]: The ID or name of the service.
    def delete name
        @connection.delete("/services/#{name}")
    end
end

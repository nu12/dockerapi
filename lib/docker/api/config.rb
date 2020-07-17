# This class represents the Docker API endpoints regarding configs.
#
# @see https://docs.docker.com/engine/api/v1.40/#tag/Config
#
# Configs are application configurations that can be used by services. Swarm mode must be enabled for these endpoints to work.
class Docker::API::Config < Docker::API::Base

    # List configs
    #
    # Docker API: GET /configs
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ConfigList
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def list params = {}
        validate Docker::API::InvalidParameter, [:filters], params
        @connection.get(build_path("/configs",params))
    end

    # Create a config
    #
    # Docker API: POST /configs/create
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ConfigCreate
    #
    # @param body [Hash]: Request body to be sent as json.
    def create body = {}
        validate Docker::API::InvalidRequestBody, [:Name, :Labels, :Data, :Templating], body
        @connection.request(method: :post, path: "/configs/create", headers: {"Content-Type": "application/json"}, body: body.to_json)
    end

    # Inspect a config
    #
    # Docker API: GET /configs/{id}
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ConfigInspect
    #
    # @param name [String]: The ID or name of the config.
    def details name
        @connection.get("/configs/#{name}")
    end

    # Update a config
    #
    # Docker API: POST /configs/{id}/update
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ConfigUpdate
    #
    # @param name [String]: The ID or name of the config.
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    #
    # @param body [Hash]: Request body to be sent as json.
    def update name, params = {}, body = {}
        validate Docker::API::InvalidParameter, [:version], params
        validate Docker::API::InvalidRequestBody, [:Name, :Labels, :Data, :Driver, :Templating], body
        @connection.request(method: :post, path: build_path("/configs/#{name}/update",params), headers: {"Content-Type": "application/json"}, body: body.to_json)
    end

    # Delete a config
    #
    # Docker API: DELETE /configs/{id}
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ConfigDelete
    #
    # @param name [String]: The ID or name of the config.
    def delete name
        @connection.delete("/configs/#{name}")
    end
end
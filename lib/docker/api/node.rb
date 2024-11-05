# This class represents the Docker API endpoints regarding nodes.
#
# Nodes are instances of the Engine participating in a swarm. Swarm mode must be enabled for these endpoints to work.
# @see https://docs.docker.com/engine/api/v1.40/#tag/Node
class Docker::API::Node < Docker::API::Base

    ##
    # List nodes.
    #
    # Docker API: GET /nodes
    # @see https://docs.docker.com/engine/api/v1.40/#operation/NodeList
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def list params = {}
        @connection.get(build_path("/nodes", params))
    end

    ##
    # Update a node.
    #
    # Docker API: POST /nodes/{id}/update
    # @see https://docs.docker.com/engine/api/v1.40/#operation/NodeUpdate
    #
    # @param name [String]: The ID or name of the node.
    # @param params [Hash]: Parameters that are appended to the URL.
    # @param body [Hash]: Request body to be sent as json.
    def update name, params = {}, body = {}
        @connection.request(method: :post, path: build_path("/nodes/#{name}/update", params), headers: {"Content-Type": "application/json"}, body: body.to_json)
    end

    ##
    # Delete a node.
    #
    # Docker API: DELETE /nodes/{id}
    # @see https://docs.docker.com/engine/api/v1.40/#operation/NodeDelete
    #
    # @param name [String]: The ID or name of the node.
    # @param params [Hash]: Parameters that are appended to the URL.
    def delete name, params = {}
        @connection.delete(build_path("/nodes/#{name}", params))
    end

    ##
    # Inspect a node.
    #
    # Docker API: GET /nodes/{id}
    # @see https://docs.docker.com/engine/api/v1.40/#operation/NodeInspect
    #
    # @param name [String]: The ID or name of the node.
    def details name
        @connection.get("/nodes/#{name}")
    end
end
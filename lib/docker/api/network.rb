##
# This class represents the Docker API endpoints regarding networks.
# @see https://docs.docker.com/engine/api/v1.40/#tag/Network
class Docker::API::Network < Docker::API::Base

    ##
    # List networks.
    #
    # Docker API: GET /networks
    # @see https://docs.docker.com/engine/api/v1.40/#operation/NetworkList
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def list params = {}
        @connection.get(build_path("/networks", params))
    end

    ##
    # Inspect a network.
    #
    # Docker API: GET /networks/{id}
    # @see https://docs.docker.com/engine/api/v1.40/#operation/NetworkInspect
    #
    # @param name [String]: The ID or name of the network.
    # @param params [Hash]: Parameters that are appended to the URL.
    def details name, params = {}
        @connection.get(build_path("/networks/#{name}", params))
    end

    ##
    # Create a network.
    #
    # Docker API: POST /networks/create
    # @see https://docs.docker.com/engine/api/v1.40/#operation/NetworkCreate
    #
    # @param body [Hash]: Request body to be sent as json.
    def create body = {}
        @connection.request(method: :post, path: build_path("/networks/create"), headers: {"Content-Type": "application/json"}, body: body.to_json)
    end

    ##
    # Remove a network.
    #
    # Docker API: DELETE /networks/{id}
    # @see https://docs.docker.com/engine/api/v1.40/#operation/NetworkDelete
    #
    # @param name [String]: The ID or name of the network.
    def remove name
        @connection.delete(build_path("/networks/#{name}"))
    end

    ##
    # Delete unused networks.
    #
    # Docker API: POST /networks/prune
    # @see https://docs.docker.com/engine/api/v1.40/#operation/NetworkPrune
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def prune params = {}
        @connection.post(build_path("/networks/prune", params))
    end

    ##
    # Connect a container to a network.
    #
    # Docker API: POST /networks/{id}/connect
    # @see https://docs.docker.com/engine/api/v1.40/#operation/NetworkConnect
    #
    # @param name [String]: The ID or name of the network.
    # @param body [Hash]: Request body to be sent as json.
    def connect name, body = {}
        @connection.request(method: :post, path: build_path("/networks/#{name}/connect"), headers: {"Content-Type": "application/json"}, body: body.to_json)
    end

    ##
    # Disconnect a container from a network.
    #
    # Docker API: POST /networks/{id}/disconnect
    # @see https://docs.docker.com/engine/api/v1.40/#operation/NetworkDisconnect
    #
    # @param name [String]: The ID or name of the network.
    # @param body [Hash]: Request body to be sent as json.
    def disconnect name, body = {}
        @connection.request(method: :post, path: build_path("/networks/#{name}/disconnect"), headers: {"Content-Type": "application/json"}, body: body.to_json)
    end

end
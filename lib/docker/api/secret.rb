# This class represents the Docker API endpoints regarding secrets.
#
# @see https://docs.docker.com/engine/api/v1.40/#tag/Secret
#
# Secrets are sensitive data that can be used by services. Swarm mode must be enabled for these endpoints to work.
class Docker::API::Secret < Docker::API::Base

    # List secrets
    #
    # Docker API: GET /secrets
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/SecretList
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def list params = {}
        @connection.get(build_path("/secrets",params))
    end

    # Create a secret
    #
    # Docker API: POST /secrets/create
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/SecretCreate
    #
    # @param body [Hash]: Request body to be sent as json.
    def create body = {}
        @connection.request(method: :post, path: "/secrets/create", headers: {"Content-Type": "application/json"}, body: body.to_json)
    end

    # Inspect a secret
    #
    # Docker API: GET /secrets/{id}
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/SecretInspect
    #
    # @param name [String]: The ID or name of the secret.
    def details name
        @connection.get("/secrets/#{name}")
    end

    # Update a secret
    #
    # Docker API: POST /secrets/{id}/update
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/SecretUpdate
    #
    # @param name [String]: The ID or name of the secret.
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    #
    # @param body [Hash]: Request body to be sent as json.
    def update name, params = {}, body = {}
        @connection.request(method: :post, path: build_path("/secrets/#{name}/update",params), headers: {"Content-Type": "application/json"}, body: body.to_json)
    end

    # Delete a secret
    #
    # Docker API: DELETE /secrets/{id}
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/SecretDelete
    #
    # @param name [String]: The ID or name of the secret.
    def delete name
        @connection.delete("/secrets/#{name}")
    end
end
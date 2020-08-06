##
# This class represents the Docker API exec related endpoints.
# @see https://docs.docker.com/engine/api/v1.40/#tag/Exec
class Docker::API::Exec < Docker::API::Base

    ##
    # Run a command inside a running container.
    #
    # Docker API: POST /containers/{id}/exec
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerExec
    #
    # @param name [String]: The ID or name of the container.
    # @param body [Hash]: Request body to be sent as json.
    def create name, body = {}
        @connection.request(method: :post, path: "/containers/#{name}/exec", headers: {"Content-Type": "application/json"}, body: body.to_json )
    end

    ##
    # Starts a previously set up exec instance.
    #
    # Docker API: POST /exec/{id}/start
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ExecStart
    #
    # @param name [String]: Exec instance ID.
    # @param body [Hash]: Request body to be sent as json.
    # @param &block: Replace the default output to stdout behavior.
    def start name, body = {}, &block
        @connection.request(method: :post, path: "/exec/#{name}/start", headers: {"Content-Type": "application/json"},  body: body.to_json, 
            response_block: block_given? ? block.call : default_streamer )
    end

    ##
    # Resize the TTY session used by an exec instance.
    #
    # Docker API: POST /exec/{id}/resize
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ExecResize
    #
    # @param name [String]: Exec instance ID.
    # @param body [Hash]: Request body to be sent as json.
    def resize name, params = {}
        @connection.post(build_path("/exec/#{name}/resize", params))
    end

    ##
    # Return low-level information about an exec instance.
    #
    # Docker API: GET /exec/{id}/json
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ExecInspect
    #
    # @param name [String]: Exec instance ID.
    def details name
        @connection.get("/exec/#{name}/json")
    end

end
##
# This class represents the Docker API system related endpoints.
# @see https://docs.docker.com/engine/api/v1.40/#tag/System
class Docker::API::System < Docker::API::Base

    ##
    # Validate credentials for a registry and, if available, get an identity token for accessing the registry without password.
    #
    # Docker API: POST /auth
    # @see https://docs.docker.com/engine/api/v1.40/#operation/SystemAuth
    #
    # @param body [Hash]: Request body to be sent as json.
    def auth body = {}
        @connection.request(method: :post, path: "/auth", headers: { "Content-Type" => "application/json" }, body: body.to_json)
    end

    ##
    # Stream real-time events from the server.
    #
    # Docker API: GET /events
    # @see https://docs.docker.com/engine/api/v1.40/#operation/SystemEvents
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    # @param &block: Replace the default output to stdout behavior.
    def events params = {}, &block
        @connection.request(method: :get, path: build_path("/events", params), response_block: block_given? ? block : default_streamer )
    end

    ##
    # This is a dummy endpoint you can use to test if the server is accessible.
    #
    # Docker API: GET /_ping
    # @see https://docs.docker.com/engine/api/v1.40/#operation/SystemPing
    def ping
        @connection.get("/_ping")
    end

    ##
    # Get system information.
    #
    # Docker API: GET /info
    # @see https://docs.docker.com/engine/api/v1.40/#operation/SystemInfo
    def info
        @connection.get("/info")
    end

    ##
    # Returns the version of Docker that is running and various information about the system that Docker is running on.
    #
    # Docker API: GET /version
    # @see https://docs.docker.com/engine/api/v1.40/#operation/SystemVersion
    def version
        @connection.get("/version")
    end

    ##
    # Get data usage information.
    #
    # Docker API: GET /system/df
    # @see https://docs.docker.com/engine/api/v1.40/#operation/SystemDataUsage
    def df
        @connection.get("/system/df")
    end
                
end
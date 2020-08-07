##
# This class represents the Docker API endpoints regarding swamrs.
# @see https://docs.docker.com/engine/api/v1.40/#tag/Swarm
class Docker::API::Swarm < Docker::API::Base

    ##
    # Initialize a new swarm.
    #
    # Docker API: POST /swarm/init
    # @see https://docs.docker.com/engine/api/v1.40/#operation/SwarmInit
    #
    # @param body [Hash]: Request body to be sent as json.
    def init body = {}
        @connection.request(method: :post, path: build_path("/swarm/init"), headers: {"Content-Type": "application/json"}, body: body.to_json)
    end

    ##
    # Update a swarm.
    #
    # Docker API: POST /swarm/update
    # @see https://docs.docker.com/engine/api/v1.40/#operation/SwarmUpdate
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    # @param body [Hash]: Request body to be sent as json.
    def update params = {}, body = {}
        @connection.request(method: :post, path: build_path("/swarm/update", params), headers: {"Content-Type": "application/json"}, body: body.to_json)
    end

    ##
    # Inspect swarm.
    #
    # Docker API: GET /swarm
    # @see https://docs.docker.com/engine/api/v1.40/#operation/SwarmInspect
    def details
        @connection.get("/swarm")
    end

    ##
    # Get the unlock key.
    #
    # Docker API: GET /swarm/unlockkey
    # @see https://docs.docker.com/engine/api/v1.40/#operation/SwarmUnlockkey 
    def unlock_key
        @connection.get("/swarm/unlockkey")
    end

    ##
    # Unlock a locked manager.
    #
    # Docker API: POST /swarm/unlock
    # @see https://docs.docker.com/engine/api/v1.40/#operation/SwarmUnlock
    #
    # @param body [Hash]: Request body to be sent as json.
    def unlock body = {}
        @connection.request(method: :post, path: "/swarm/unlock", headers: {"Content-Type": "application/json"}, body: body.to_json)
    end

    ##
    # Join an existing swarm.
    #
    # Docker API: POST /swarm/join
    # @see https://docs.docker.com/engine/api/v1.40/#operation/SwarmJoin
    #
    # @param body [Hash]: Request body to be sent as json.
    def join body = {}
        @connection.request(method: :post, path: "/swarm/join", headers: {"Content-Type": "application/json"}, body: body.to_json)
    end

    ##
    # Leave a swarm.
    #
    # Docker API: POST /swarm/leave
    # @see https://docs.docker.com/engine/api/v1.40/#operation/SwarmLeave
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def leave params = {}
        @connection.post(build_path("/swarm/leave", params))
    end
end
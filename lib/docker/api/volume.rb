##
# This class represents the Docker API endpoints regarding volumes.
# @see https://docs.docker.com/engine/api/v1.40/#tag/Volume
class Docker::API::Volume < Docker::API::Base

    ##
    # List volumes.
    #
    # Docker API: GET
    # @see https://docs.docker.com/engine/api/v1.40/#operation/VolumeList
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def list params = {}
        @connection.get(build_path("/volumes", params))
    end

    ##
    # Inspect a volume.
    #
    # Docker API: GET /volumes/{name}
    # @see https://docs.docker.com/engine/api/v1.40/#operation/VolumeInspect
    #
    # @param name [String]: The ID or name of the volume.
    def details name
        @connection.get("/volumes/#{name}")
    end

    ##
    # Create a volume.
    #
    # Docker API: POST /volumes/create
    # @see https://docs.docker.com/engine/api/v1.40/#operation/VolumeCreate
    #
    # @param body [Hash]: Request body to be sent as json.
    def create body = {}
        @connection.request(method: :post, path: "/volumes/create", headers: {"Content-Type": "application/json"}, body: body.to_json)
    end

    ##
    # Remove a volume.
    #
    # Docker API: DELETE /volumes/{name}
    # @see https://docs.docker.com/engine/api/v1.40/#operation/VolumeDelete
    #
    # @param name [String]: The ID or name of the volume.
    # @param params [Hash]: Parameters that are appended to the URL.
    def remove name, params = {}
        @connection.delete(build_path("/volumes/#{name}",params))
    end

    ##
    # Delete unused volumes.
    #
    # Docker API: POST /volumes/prune
    # @see https://docs.docker.com/engine/api/v1.40/#operation/VolumePrune
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def prune params = {}
        @connection.post(build_path("/volumes/prune", params))
    end
end

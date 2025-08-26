##
# This class represents the Docker API endpoints regarding containers.
# @see https://docs.docker.com/engine/api/v1.40/#tag/Container
class Docker::API::Container < Docker::API::Base

    ##
    # Return a list of containers.
    #
    # Docker API: GET /containers/json
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerList
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def list params = {}
        get("/containers/json", params)
    end

    ##
    # Return low-level information about a container.
    #
    # Docker API: GET /containers/{id}/json
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerInspect
    #
    # @param name [String]: The ID or name of the container.
    # @param params [Hash]: Parameters that are appended to the URL.
    def details name, params = {}
        get("/containers/#{name}/json", params)
    end

    ##
    # List processes running inside a container.
    #
    # Docker API: GET /containers/{id}/top
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerTop
    #
    # @param name [String]: The ID or name of the container.
    # @param params [Hash]: Parameters that are appended to the URL.
    def top name, params = {}
        get("/containers/#{name}/top", params)
    end

    ##
    # Get changes on a container’s filesystem.
    #
    # Docker API: GET /containers/{id}/changes
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerChanges
    #
    # @param name [String]: The ID or name of the container.
    def changes name
        get("/containers/#{name}/changes")
    end

    ##
    # Start a container.
    #
    # Docker API: POST /containers/{id}/start
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerStart
    #
    # @param name [String]: The ID or name of the container.
    # @param params [Hash]: Parameters that are appended to the URL.
    def start name, params = {}
        post("/containers/#{name}/start", params)
    end

    ##
    # Stop a container.
    #
    # Docker API: POST /containers/{id}/stop
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerStop
    #
    # @param name [String]: The ID or name of the container.
    # @param params [Hash]: Parameters that are appended to the URL.
    def stop name, params = {}
        post("/containers/#{name}/stop", params)
    end

    ##
    # Restart a container.
    #
    # Docker API: POST /containers/{id}/restart
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerRestart
    #
    # @param name [String]: The ID or name of the container.
    # @param params [Hash]: Parameters that are appended to the URL.
    def restart name, params = {}
        post("/containers/#{name}/restart", params)
    end

    ##
    # Send a POSIX signal to a container, defaulting to killing to the container.
    #
    # Docker API: POST /containers/{id}/kill
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerKill
    #
    # @param name [String]: The ID or name of the container.
    # @param params [Hash]: Parameters that are appended to the URL.
    def kill name, params = {}
        post("/containers/#{name}/kill", params)
    end

    ##
    # Block until a container stops, then returns the exit code.
    #
    # Docker API: POST /containers/{id}/wait
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerWait
    #
    # @param name [String]: The ID or name of the container.
    # @param params [Hash]: Parameters that are appended to the URL.
    def wait name, params = {}
        post("/containers/#{name}/wait", params)
    end

    ##
    # Change various configuration options of a container without having to recreate it.
    #
    # Docker API: POST /containers/{id}/update
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerUpdate
    #
    # @param name [String]: The ID or name of the container.
    # @param body [Hash]: Request body to be sent as json.
    def update name, body = {}
        request(method: :post, path: "/containers/#{name}/update", headers: {"Content-Type": "application/json"}, body: body.to_json)
    end

    ##
    # Rename a container.
    #
    # Docker API: POST /containers/{id}/rename
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerRename
    #
    # @param name [String]: The ID or name of the container.
    # @param params [Hash]: Parameters that are appended to the URL.
    def rename name, params = {}
        post("/containers/#{name}/rename", params)
    end

    ##
    # Resize the TTY for a container.
    #
    # Docker API: POST /containers/{id}/resize
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerResize
    #
    # @param name [String]: The ID or name of the container.
    # @param params [Hash]: Parameters that are appended to the URL.
    def resize name, params = {}
        post("/containers/#{name}/resize", params)
    end

    ##
    # Delete stopped containers.
    #
    # Docker API: POST /containers/prune
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerPrune
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def prune params = {}
        post("/containers/prune", params)
    end

    ##
    # Pause a container. 
    #
    # Docker API: POST /containers/{id}/pause
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerPause
    #
    # @param name [String]: The ID or name of the container.
    def pause name
        post("/containers/#{name}/pause")
    end

    ##
    # Resume a container which has been paused.
    #
    # Docker API: POST /containers/{id}/unpause
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerUnpause
    #
    # @param name [String]: The ID or name of the container.
    def unpause name
        post("/containers/#{name}/unpause")
    end

    ##
    # Remove a container.
    #
    # Docker API: DELETE /containers/{id}
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerDelete
    #
    # @param name [String]: The ID or name of the container.
    # @param params [Hash]: Parameters that are appended to the URL.
    def remove name, params = {}
        delete("/containers/#{name}", params)
    end

    ##
    # Get stdout and stderr logs from a container.
    #
    # Docker API: GET /containers/{id}/logs
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerLogs
    #
    # @param name [String]: The ID or name of the container.
    # @param params [Hash]: Parameters that are appended to the URL.
    # @param &block: Replace the default output to stdout behavior.
    def logs name, params = {}, &block
        path = "/containers/#{name}/logs"

        if [true, 1 ].include? params[:follow]
            request(method: :get, path: path, params: params, response_block: block_given? ? block : default_streamer)
        else
            get(path, params)
        end
    end

    ##
    # Attach to a container.
    #
    # Docker API: POST /containers/{id}/attach
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerAttach
    #
    # @param name [String]: The ID or name of the container.
    # @param params [Hash]: Parameters that are appended to the URL.
    # @param &block: Replace the default output to stdout behavior.
    def attach name, params = {}, &block
        request(method: :post, path: "/containers/#{name}/attach", params: params , response_block: block_given? ? block : default_streamer)
    end

    ##
    # Create a container.
    #
    # Docker API: POST /containers/create
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerCreate
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    # @param body [Hash]: Request body to be sent as json.
    def create params = {}, body = {}
        request(method: :post, path: "/containers/create", params: params, headers: {"Content-Type": "application/json"}, body: body.to_json)
    end

    ##
    # Get container stats based on resource usage.
    #
    # Docker API: GET /containers/{id}/stats
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerStats
    #
    # @param name [String]: The ID or name of the container.
    # @param params [Hash]: Parameters that are appended to the URL.
    # @param &block: Replace the default output to stdout behavior.
    def stats name, params = {}, &block
        path = "/containers/#{name}/stats"

        if [true, 1 ].include? params[:stream]
            request(method: :get, path: path, params: params, response_block: block_given? ? block : default_streamer)
        else
            get(path, params)
        end
    end

    ##
    # Export the contents of a container as a tarball.
    #
    # Docker API: GET /containers/{id}/export
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerExport
    #
    # @param name [String]: The ID or name of the container.
    # @param path [String]: Path to the exportated file.
    # @param &block: Replace the default file writing behavior.
    def export name, path, &block
        response = self.details(name)
        return response unless response.status == 200
        request(method: :get, path: "/containers/#{name}/export", response_block: block_given? ? block : default_writer(path))
    end

    ##
    # Get an archive of a filesystem resource in a container.
    #
    # Get a tar archive of a resource in the filesystem of container id.
    #
    # Docker API: GET /containers/{id}/archive
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ContainerArchive
    #
    # @param name [String]: The ID or name of the container.
    # @param path [String]: Path to the exportated file.
    # @param params [Hash]: Parameters that are appended to the URL.
    # @param &block: Replace the default file writing behavior.
    def get_archive name, path, params = {}, &block
        response = head("/containers/#{name}/archive", params)
        return response unless response.status == 200 
        
        file = File.open( File.expand_path( path ) , "wb")
        response = request(method: :get, path: "/containers/#{name}/archive", params: params , response_block: block_given? ? block : lambda { |chunk, remaining_bytes, total_bytes| file.write(chunk) })
        file.close
        response
    end

    ##
    # Extract an archive of files or folders to a directory in a container.
    #
    # Upload a tar archive to be extracted to a path in the filesystem of container id.
    #
    # Docker API: PUT /containers/{id}/archive
    # @see https://docs.docker.com/engine/api/v1.40/#operation/PutContainerArchive
    #
    # @param name [String]: The ID or name of the container.
    # @param path [String]: Path of the tar file.
    # @param params [Hash]: Parameters that are appended to the URL.
    def put_archive name, path, params = {}
        file = File.open( File.expand_path( path ) , "r")
        response = request(method: :put, path: "/containers/#{name}/archive", params: params , request_block: lambda { file.read(Excon.defaults[:chunk_size]).to_s} )
        file.close
        response
    end
end
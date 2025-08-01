##
# This class represents the Docker API endpoints regarding images.
# @see https://docs.docker.com/engine/api/v1.40/#tag/Image
class Docker::API::Image < Docker::API::Base

    ##
    # Return low-level information about an image.
    #
    # Docker API: GET /images/{name}/json
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ImageInspect
    #
    # @param name [String]: The ID or name of the image.
    def details name
        @connection.get(build_path("/images/#{name}/json"))
    end

    ##
    # Return image digest and platform information by contacting the registry.
    #
    # Docker API: GET /distribution/{name}/json
    # @see https://docs.docker.com/engine/api/v1.40/#tag/Distribution
    #
    # @param name [String]: The ID or name of the image.
    # @param authentication [Hash]: Authentication parameters.
    def distribution name, authentication = {}
        request = {method: :get, path: build_path("/distribution/#{name}/json")}
        request[:headers] = {"X-Registry-Auth" => auth_encoder(authentication)} if authentication.any?
        @connection.request(request)
    end

    ##
    # Return parent layers of an image.
    #
    # Docker API: GET /images/{name}/history
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ImageHistory
    #
    # @param name [String]: The ID or name of the image.
    def history name
        @connection.get(build_path("/images/#{name}/history"))
    end

    ##
    # Return a list of images on the server. Note that it uses a different, smaller representation of an image than inspecting a single image.
    #
    # Docker API: GET /images/json
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ImageList
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def list params = {}
        @connection.get(build_path("/images/json", params)) 
    end

    ##
    # Search for an image on Docker Hub.
    #
    # Docker API: GET /images/search
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ImageSearch
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def search params = {}
        @connection.get(build_path("/images/search", params)) 
    end

    ##
    # Tag an image so that it becomes part of a repository.
    #
    # Docker API: POST /images/{name}/tag
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ImageTag
    #
    # @param name [String]: The ID or name of the image.
    # @param params [Hash]: Parameters that are appended to the URL.
    def tag name, params = {}
        @connection.post(build_path("/images/#{name}/tag", params))
    end

    ##
    # Delete unused images.
    #
    # Docker API: POST /images/prune
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ImagePrune
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def prune params = {}
        @connection.post(build_path("/images/prune", params))
    end

    ##
    # Remove an image, along with any untagged parent images that were referenced by that image.
    #
    # Images can't be removed if they have descendant images, are being used by a running container or are being used by a build.
    #
    # Docker API: DELETE /images/{name}
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ImageDelete
    #
    # @param name [String]: The ID or name of the image.
    # @param params [Hash]: Parameters that are appended to the URL.
    def remove name, params = {}
        @connection.delete(build_path("/images/#{name}", params))
    end

    ##
    # Export an image.
    #
    # Docker API: GET /images/{name}/get
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ImageGet
    #
    # @param name [String]: The ID or name of the image.
    # @param path [String]: Path to the exported file.
    # @param &block: Replace the default file writing behavior.
    def export name, path, &block
        @connection.request(method: :get, path: build_path("/images/#{name}/get") , response_block: block_given? ? block : default_writer(path))
    end

    ##
    # Import images.
    #
    # Docker API: POST /images/load
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ImageLoad
    #
    # @param name [String]: The ID or name of the image.
    # @param params [Hash]: Parameters that are appended to the URL.
    def import path, params = {}
        default_reader(path, build_path("/images/load", params))
    end

    ##
    # Push an image to a registry.
    #
    # Docker API: POST /images/{name}/push
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ImagePush
    #
    # @param name [String]: The ID or name of the image.
    # @param params [Hash]: Parameters that are appended to the URL.
    # @param authentication [Hash]: Authentication parameters.
    def push name, params = {}, authentication = {}
        raise Docker::API::Error.new("Provide authentication parameters to push an image") unless authentication.any?
        @connection.request(method: :post, path: build_path("/images/#{name}/push", params), headers: { "X-Registry-Auth" => auth_encoder(authentication) } )
    end

    ##
    # Create a new image from a container.
    #
    # Docker API: POST /commit
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ImageCommit
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    # @param body [Hash]: Request body to be sent as json.
    def commit params = {}, body = {}
        container = Docker::API::Container.new(@connection).details(params[:container])
        return container if [404, 301].include? container.status
        @connection.request(method: :post, path: build_path("/commit", params), headers: {"Content-Type": "application/json"}, body: container.json["Config"].merge(body).to_json)
    end

    ##
    # Create an image by either pulling it from a registry or importing it.
    #
    # Docker API: POST /images/create
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ImageCreate
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    # @param authentication [Hash]: Authentication parameters.
    # @param &block: Replace the default output to stdout behavior.
    def create params = {}, authentication = {}, &block
        request = {method: :post, path: build_path("/images/create", params), response_block: block_given? ? block : default_streamer }
        if params.has_key? :fromSrc and !params[:fromSrc].match(/^(http|https)/) # then it's using a tar file
            path = params[:fromSrc]
            params[:fromSrc] = "-"
            default_reader(path, build_path("/images/create", params))
        else
            request[:headers] = { "X-Registry-Auth" => auth_encoder(authentication) } if authentication.any?
            @connection.request(request)
        end
    end

    ##
    # Build an image from a tar archive with a Dockerfile in it.
    #
    # Docker API: POST /build
    # @see https://docs.docker.com/engine/api/v1.40/#operation/ImageBuild
    #
    # @param path [String]: Path to the tar file.
    # @param params [Hash]: Parameters that are appended to the URL.
    # @param authentication [Hash]: Authentication parameters.
    # @param &block: Replace the default output to stdout behavior.
    def build path, params = {}, authentication = {}, &block
        raise Docker::API::Error.new("Expected path or params[:remote]") unless path || params[:remote] 

        headers = {"Content-type" => "application/x-tar"}
        headers.merge!({"X-Registry-Config": auth_encoder(authentication) }) if authentication.any?

        if path == nil and params.has_key? :remote
            response = @connection.request(method: :post, path: build_path("/build", params), headers: headers, response_block: block_given? ? block : default_streamer)
        else
            default_reader(path, build_path("/build", params), headers)
        end
    end

    ##
    # Delete builder cache.
    #
    # Docker API: POST /build/prune
    # @see https://docs.docker.com/engine/api/v1.40/#operation/BuildPrune
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def delete_cache params = {}
        @connection.post(build_path("/build/prune", params))
    end
end
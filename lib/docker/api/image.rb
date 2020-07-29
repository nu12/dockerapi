
class Docker::API::Image < Docker::API::Base

    def details name
        @connection.get("/images/#{name}/json")
    end

    def distribution name
        @connection.get("/distribution/#{name}/json")
    end

    def history name
        @connection.get("/images/#{name}/history")
    end

    def list params = {}
        @connection.get(build_path("/images/json", params)) 
    end

    def search params = {}
        @connection.get(build_path("/images/search", params)) 
    end

    def tag name, params = {}
        @connection.post(build_path("/images/#{name}/tag", params))
    end

    def prune params = {}
        @connection.post(build_path("/images/prune", params))
    end

    def remove name, params = {}
        @connection.delete(build_path("/images/#{name}", params))
    end

    def export name, path = "exported_image", &block
        @connection.request(method: :get, path: build_path("/images/#{name}/get") , response_block: block_given? ? block.call : default_writer(path))
    end

    def import path, params = {}
        default_reader(path, build_path("/images/load", params))
    end

    def push name, params = {}, authentication = {}
        raise Docker::API::Error.new("Provide authentication parameters to push an image") unless authentication.keys.size > 0
        @connection.request(method: :post, path: build_path("/images/#{name}/push", params), headers: { "X-Registry-Auth" => Base64.urlsafe_encode64(authentication.to_json.to_s).chomp } )
    end

    def commit params = {}, body = {}
        container = Docker::API::Container.new.details(params[:container])
        return container if [404, 301].include? container.status
        @connection.request(method: :post, path: build_path("/commit", params), headers: {"Content-Type": "application/json"}, body: container.json["Config"].merge(body).to_json)
    end

    def create params = {}, authentication = {}, &block
        request = {method: :post, path: build_path("/images/create", params), response_block: block_given? ? block.call : default_streamer }
        if params.has_key? :fromSrc and !params[:fromSrc].match(/^(http|https)/)
            path = params[:fromSrc]
            params[:fromSrc] = "-"
            default_reader(path, build_path("/images/create", params))
        else
            request[:headers] = { "X-Registry-Auth" => Base64.encode64(authentication.to_json.to_s).chomp } if authentication.keys.size > 0
            @connection.request(request)
        end
    end

    # File reader
    def build path, params = {}, authentication = {}, &block
        raise Docker::API::Error.new("Expected path or params[:remote]") unless path || params[:remote] 

        headers = {"Content-type": "application/x-tar"}
        headers.merge!({"X-Registry-Config": Base64.urlsafe_encode64(authentication.to_json.to_s).chomp}) if authentication.keys.size > 0

        if path == nil and params.has_key? :remote
            response = @connection.request(method: :post, path: build_path("/build", params), headers: headers, response_block: block_given? ? block.call : default_streamer)
        else
            default_reader(path, build_path("/build", params), headers)
        end
    end

    def delete_cache params = {}
        @connection.post(build_path("/build/prune", params))
    end

end
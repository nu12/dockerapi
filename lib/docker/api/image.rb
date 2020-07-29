
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

    # File reader
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
        body = JSON.parse(container.body)["Config"].merge(body)
        @connection.request(method: :post, path: build_path("/commit", params), headers: {"Content-Type": "application/json"}, body: body.to_json)
    end

    # stream
    def create params = {}, authentication = {}, &block               
        if authentication.keys.size > 0
            auth = Docker::API::System.new.auth(authentication)
            return auth unless [200, 204].include? auth.status
            @connection.request(method: :post, path: build_path("/images/create", params), headers: { "X-Registry-Auth" => Base64.encode64(authentication.to_json.to_s).chomp } )
        elsif params.has_key? :fromSrc
            if params[:fromSrc].match(/^(http|https)/)
                @connection.request(method: :post, path: build_path("/images/create", params))
            else
                file = File.open(File.expand_path(params[:fromSrc]), "r")
                params[:fromSrc] = "-"
                response = @connection.request(method: :post, path: build_path("/images/create", params) , headers: {"Content-Type" => "application/x-tar"}, request_block: lambda { file.read(Excon.defaults[:chunk_size]).to_s} )
                file.close
                response
            end
        else
            @connection.request(method: :post, path: build_path("/images/create", params), response_block: block_given? ? block.call : default_streamer )
        end
    end

    # File reader
    def build path, params = {}, authentication = {}
        raise Docker::API::Error.new("Expected path or params[:remote]") unless path || params[:remote] 

        header = {"Content-type": "application/x-tar"}
        if authentication.keys.size > 0
            authentication.each_key do |server|
                auth = Docker::API::System.new.auth({username: authentication[server][:username] ,password:authentication[server][:password], serveraddress: server})
                return auth unless [200, 204].include? auth.status
            end
            header.merge!({"X-Registry-Config": Base64.urlsafe_encode64(authentication.to_json.to_s).chomp})
        end

        begin # Local
            file = File.open( File.expand_path( path ) , "r")
            response = @connection.request(method: :post, path: build_path("/build", params), headers: header, request_block: lambda { file.read(Excon.defaults[:chunk_size]).to_s})
            file.close
        rescue # Git
            response = @connection.request(method: :post, path: build_path("/build", params), headers: header)
        end
        response
    end

    def delete_cache params = {}
        @connection.post(build_path("/build/prune", params))
    end

end
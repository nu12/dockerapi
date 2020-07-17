require "base64"
require "json"
require 'fileutils'
module Docker
    module API
        CommitBody = [:Hostname, :Domainname, :User, :AttachStdin, :AttachStdout, :AttachStderr, :ExposedPorts, :Tty, :OpenStdin, :StdinOnce, :Env, :Cmd, :HealthCheck, :ArgsEscaped, :Image, :Volumes, :WorkingDir, :Entrypoint, :NetworkDisabled, :MacAddress, :OnBuild, :Labels, :StopSignal, :StopTimeout, :Shell]
        BuildParams = [:dockerfile, :t, :extrahosts, :remote, :q, :nocache, :cachefrom, :pull, :rm, :forcerm, :memory, :memswap, :cpushares, :cpusetcpus, :cpuperiod, :cpuquota, :buildargs, :shmsize, :squash, :labels, :networkmode, :platform, :target, :outputs]
        class Image < Docker::API::Base

            def details name
                @connection.get(build_path([name, "json"]))
            end

            def distribution name
                @connection.get("/distribution/#{name}/json")
            end

            def history name
                @connection.get(build_path([name, "history"]))
            end

            def list params = {}
                validate Docker::API::InvalidParameter, [:all, :filters, :digests], params
                @connection.get(build_path(["json"], params)) 
            end

            def search params = {}
                validate Docker::API::InvalidParameter, [:term, :limit, :filters], params
                @connection.get(build_path(["search"], params)) 
            end

            def tag name, params = {}
                validate Docker::API::InvalidParameter, [:repo, :tag], params
                @connection.post(build_path([name, "tag"], params))
            end

            def prune params = {}
                validate Docker::API::InvalidParameter, [:filters], params
                @connection.post(build_path(["prune"], params))
            end

            def remove name, params = {}
                validate Docker::API::InvalidParameter, [:force, :noprune], params
                @connection.delete(build_path([name], params))
            end

            def export name, path = "exported_image"
                file = File.open("/tmp/exported-image", "wb")
                streamer = lambda do |chunk, remaining_bytes, total_bytes|
                    file.write(chunk)
                end
                response = @connection.request(method: :get, path: build_path([name, "get"]) , response_block: streamer)
                file.close
                response.status == 200 ? FileUtils.mv("/tmp/exported-image", File.expand_path(path)) : FileUtils.rm("/tmp/exported-image")
                response
            end

            def import path, params = {}
                validate Docker::API::InvalidParameter, [:quiet], params
                file = File.open(File.expand_path(path), "r")
                response = @connection.request(method: :post, path: build_path(["load"], params) , headers: {"Content-Type" => "application/x-tar"}, request_block: lambda { file.read(Excon.defaults[:chunk_size]).to_s} )
                file.close
                response
            end

            def push name, params = {}, authentication = {}
                validate Docker::API::InvalidParameter, [:tag], params

                if authentication.keys.size > 0
                    @connection.request(method: :post, path: build_path([name, "push"], params), headers: { "X-Registry-Auth" => Base64.urlsafe_encode64(authentication.to_json.to_s).chomp } )
                else
                    raise Docker::API::Error.new("Provide authentication parameters to push an image")
                end
            end

            def commit params = {}, body = {}
                validate Docker::API::InvalidParameter, [:container, :repo, :tag, :comment, :author, :pause, :changes], params
                validate Docker::API::InvalidRequestBody, Docker::API::CommitBody, body
                container = Docker::API::Container.new.details(params[:container])
                return container if [404, 301].include? container.status
                body = JSON.parse(container.body)["Config"].merge(body)
                @connection.request(method: :post, path: build_path("/commit", params), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def create params = {}, authentication = {}
                validate Docker::API::InvalidParameter, [:fromImage, :fromSrc, :repo, :tag, :message, :platform], params
                
                if authentication.keys.size > 0
                    auth = Docker::API::System.new.auth(authentication)
                    return auth unless [200, 204].include? auth.status
                    @connection.request(method: :post, path: build_path(["create"], params), headers: { "X-Registry-Auth" => Base64.encode64(authentication.to_json.to_s).chomp } )
                elsif params.has_key? :fromSrc
                    if params[:fromSrc].match(/^(http|https)/)
                        @connection.request(method: :post, path: build_path(["create"], params))
                    else
                        file = File.open(File.expand_path(params[:fromSrc]), "r")
                        params[:fromSrc] = "-"
                        response = @connection.request(method: :post, path: build_path(["create"], params) , headers: {"Content-Type" => "application/x-tar"}, request_block: lambda { file.read(Excon.defaults[:chunk_size]).to_s} )
                        file.close
                        response
                    end
                else
                    @connection.post(build_path(["create"], params))
                end
            end

            def build path, params = {}, authentication = {}
                raise Docker::API::Error.new("Expected path or params[:remote]") unless path || params[:remote] 
                validate Docker::API::InvalidParameter, Docker::API::BuildParams, params

                header = {"Content-type": "application/x-tar"}
                if authentication.keys.size > 0
                    authentication.each_key do |server|
                        auth = Docker::API::System.new.auth({username: authentication[server][:username] ,password:authentication[server][:password], serveraddress: server})
                        return auth unless [200, 204].include? auth.status
                    end
                    header.merge!({"X-Registry-Config": Base64.urlsafe_encode64(authentication.to_json.to_s).chomp})
                end

                begin
                    file = File.open( File.expand_path( path ) , "r")
                    response = @connection.request(method: :post, path: build_path("/build", params), headers: header, request_block: lambda { file.read(Excon.defaults[:chunk_size]).to_s})
                    file.close
                rescue
                    response = @connection.request(method: :post, path: build_path("/build", params), headers: header)
                end
                response
            end

            def delete_cache params = {}
                validate Docker::API::InvalidParameter, [:all, "keep-storage", :filters], params
                @connection.post(build_path("/build/prune", params))
            end

            #################################################
            # Items in this area to be removed before 1.0.0 #
            #################################################
            def base_path
                "/images"
            end

            def inspect *args
                return super.inspect if args.size == 0
                warn  "WARNING: #inspect is deprecated and will be removed in the future, please use #details instead."
                name = args[0]
                details(name)
            end
            #################################################

        end
    end
end
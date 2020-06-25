require "base64"
require "json"
require 'fileutils'
module Docker
    module API
        CommitBody = [:Hostname, :Domainname, :User, :AttachStdin, :AttachStdout, :AttachStderr, :ExposedPorts, :Tty, :OpenStdin, :StdinOnce, :Env, :Cmd, :HealthCheck, :ArgsEscaped, :Image, :Volumes, :WorkingDir, :Entrypoint, :NetworkDisabled, :MacAddress, :OnBuild, :Labels, :StopSignal, :StopTimeout, :Shell]
        BuildParams = [:dockerfile, :t, :extrahosts, :remote, :q, :nocache, :cachefrom, :pull, :rm, :forcerm, :memory, :memswap, :cpushares, :cpusetcpus, :cpuperiod, :cpuquota, :buildargs, :shmsize, :squash, :labels, :networkmode, :platform, :target, :outputs]
        class Image < Docker::API::Base

            def self.base_path
                "/images"
            end

            [{name: "inspect", path: "json"},
             {name: "history", path: "history"}].each do | method |
                define_singleton_method(method[:name]) { | name | connection.get(build_path([name, method[:path]])) }
            end

            [{name: "list",     path: "json",   params: [:all, :filters, :digests]},
             {name: "search",   path: "search", params: [:term, :limit, :filters]}].each do | method |
                define_singleton_method(method[:name]) do | params = {} | 
                    validate Docker::API::InvalidParameter, method[:params], params
                    connection.get(build_path([method[:path]], params)) 
                end
            end

            def self.export name, path = "exported_image"
                file = File.open("/tmp/exported-image", "wb")
                streamer = lambda do |chunk, remaining_bytes, total_bytes|
                    file.write(chunk)
                end
                response = connection.request(method: :get, path: build_path([name, "get"]) , response_block: streamer)
                file.close
                response.status == 200 ? FileUtils.mv("/tmp/exported-image", File.expand_path(path)) : FileUtils.rm("/tmp/exported-image")
                response
            end

            def self.import path, params = {}
                validate Docker::API::InvalidParameter, [:quiet], params
                file = File.open(File.expand_path(path), "r")
                response = connection.request(method: :post, path: build_path(["load"], params) , headers: {"Content-Type" => "application/x-tar"}, request_block: lambda { file.read(Excon.defaults[:chunk_size]).to_s} )
                file.close
                response
            end

            def self.push name, params = {}, authentication = {}
                validate Docker::API::InvalidParameter, [:tag], params

                if authentication.keys.size > 0
                    auth = Docker::API::System.auth(authentication)
                    return auth unless [200, 204].include? auth.status
                    connection.request(method: :post, path: build_path([name, "push"], params), headers: { "X-Registry-Auth" => Base64.encode64(authentication.to_json.to_s).chomp } )
                else
                    connection.post(build_path([name, "push"], params))
                end
            end

            def self.commit params = {}, body = {}
                validate Docker::API::InvalidParameter, [:container, :repo, :tag, :comment, :author, :pause, :changes], params
                validate Docker::API::InvalidRequestBody, Docker::API::CommitBody, body
                container = Docker::API::Container.inspect(params[:container])
                return container if [404, 301].include? container.status
                body = JSON.parse(container.body)["Config"].merge(body)
                connection.request(method: :post, path: build_path("/commit", params), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def self.remove name, params = {}
                validate Docker::API::InvalidParameter, [:force, :noprune], params
                connection.delete(build_path([name], params))
            end

            def self.tag name, params = {}
                validate Docker::API::InvalidParameter, [:repo, :tag], params
                connection.post(build_path([name, "tag"], params))
            end

            def self.prune params = {}
                validate Docker::API::InvalidParameter, [:filters], params
                connection.post(build_path(["prune"], params))
            end

            def self.create params = {}, authentication = {}
                validate Docker::API::InvalidParameter, [:fromImage, :fromSrc, :repo, :tag, :message, :platform], params
                
                if authentication.keys.size > 0
                    auth = Docker::API::System.auth(authentication)
                    return auth unless [200, 204].include? auth.status
                    connection.request(method: :post, path: build_path(["create"], params), headers: { "X-Registry-Auth" => Base64.encode64(authentication.to_json.to_s).chomp } )
                elsif params.has_key? :fromSrc
                    if params[:fromSrc].match(/^(http|https)/)
                        connection.request(method: :post, path: build_path(["create"], params))
                    else
                        file = File.open(File.expand_path(params[:fromSrc]), "r")
                        params[:fromSrc] = "-"
                        response = connection.request(method: :post, path: build_path(["create"], params) , headers: {"Content-Type" => "application/x-tar"}, request_block: lambda { file.read(Excon.defaults[:chunk_size]).to_s} )
                        file.close
                        response
                    end
                else
                    connection.post(build_path(["create"], params))
                end
            end

            def self.build path, params = {}, authentication = {}
                raise Docker::API::InvalidRequestBody unless path || params[:remote] 
                validate Docker::API::InvalidParameter, Docker::API::BuildParams, params

                header = {"Content-type": "application/x-tar"}
                if authentication.keys.size > 0
                    authentication.each_key do |server|
                        auth = Docker::API::System.auth({username: authentication[server][:username] ,password:authentication[server][:password], serveraddress: server})
                        return auth unless [200, 204].include? auth.status
                    end
                    header.merge({"X-Registry-Config": Base64.encode64(authentication.to_json.to_s).chomp})
                end

                begin
                    file = File.open( File.expand_path( path ) , "r")
                    response = connection.request(method: :post, path: build_path("/build", params), headers: header, request_block: lambda { file.read(Excon.defaults[:chunk_size]).to_s})
                    file.close
                rescue
                    response = connection.request(method: :post, path: build_path("/build", params), headers: header)
                end
                response
            end

        end

    end
end
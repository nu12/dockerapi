module Docker
    module API
        class Container < Docker::API::Base

            def list params = {}
                @connection.get(build_path(["json"], params))
            end

            def details name, params = {}
                @connection.get(build_path([name, "json"], params))
            end

            def top name, params = {}
                @connection.get(build_path([name, "top"], params))
            end

            def changes name
                @connection.get(build_path([name, "changes"]))
            end

            def start name, params = {}
                @connection.post(build_path([name, "start"], params))
            end

            def stop name, params = {}
                @connection.post(build_path([name, "stop"], params))
            end

            def restart name, params = {}
                @connection.post(build_path([name, "restart"], params))
            end

            def kill name, params = {}
                @connection.post(build_path([name, "kill"], params))
            end

            def wait name, params = {}
                @connection.post(build_path([name, "wait"], params))
            end

            def update name, body = {}
                @connection.request(method: :post, path: build_path([name, "update"]), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def rename name, params = {}
                @connection.post(build_path([name, "rename"], params))
            end

            def resize name, params = {}
                @connection.post(build_path([name, "resize"], params))
            end

            def prune params = {}
                @connection.post(build_path(["prune"], params))
            end

            def pause name
                @connection.post(build_path([name, "pause"]))
            end

            def unpause name
                @connection.post(build_path([name, "unpause"]))
            end

            def remove name, params = {}
                @connection.delete(build_path([name]))
            end

            def logs name, params = {}
                
                path = build_path([name, "logs"], params)

                if params[:follow] == true || params[:follow] == 1
                    @connection.request(method: :get, path: path , response_block: lambda { |chunk, remaining_bytes, total_bytes| puts chunk.inspect })
                else
                    @connection.get(path)
                end
            end

            def attach name, params = {}
                @connection.request(method: :post, path: build_path([name, "attach"], params) , response_block: lambda { |chunk, remaining_bytes, total_bytes| puts chunk.inspect })
            end

            def create params = {}, body = {}
                @connection.request(method: :post, path: build_path(["create"], params), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def stats name, params = {}
                path = build_path([name, "stats"], params)

                if params[:stream] == true || params[:stream] == 1
                    streamer = lambda do |chunk, remaining_bytes, total_bytes|
                        puts chunk
                    end
                    @connection.request(method: :get, path: path , response_block: streamer)
                else
                    @connection.get(path)
                end
            end

            def export name, path = "exported_container"
                response = self.details(name)
                if response.status == 200
                    file = File.open(File.expand_path(path), "wb")
                    streamer = lambda do |chunk, remaining_bytes, total_bytes|
                        file.write(chunk)
                    end
                    response = @connection.request(method: :get, path: build_path([name, "export"]) , response_block: streamer)
                    file.close
                end
                response
            end

            def archive name, file, params = {}

                begin # File exists on disk, send it to container
                    file = File.open( File.expand_path( file ) , "r")
                    response = @connection.request(method: :put, path: build_path([name, "archive"], params) , request_block: lambda { file.read(Excon.defaults[:chunk_size]).to_s} )
                    file.close
                rescue Errno::ENOENT # File doesnt exist, get it from container
                    response = @connection.head(build_path([name, "archive"], params))
                    if response.status == 200 # file exists in container
                        file = File.open( File.expand_path( file ) , "wb")
                        response = @connection.request(method: :get, path: build_path([name, "archive"], params) , response_block: lambda { |chunk, remaining_bytes, total_bytes| file.write(chunk) })
                        file.close
                    end
                end
                response
            end

            #################################################
            # Items in this area to be removed before 1.0.0 #
            #################################################
            def base_path
                "/containers"
            end

            def inspect *args
                return super.inspect if args.size == 0
                warn  "WARNING: #inspect is deprecated and will be removed in the future, please use #details instead."
                name, params = args[0], args[1] || {}
                details(name, params)
            end
            #################################################

        end
    end
end
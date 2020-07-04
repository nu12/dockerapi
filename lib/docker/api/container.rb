module Docker
    module API
        CreateBody = [:Hostname,:Domainname,:User,:AttachStdin,:AttachStdout,:AttachStderr,:ExposedPorts,:Tty,:OpenStdin,:StdinOnce,:Env,:Cmd,:HealthCheck,:ArgsEscaped,:Image,:Volumes,:WorkingDir,:Entrypoint,:NetworkDisabled,:MacAddress,:OnBuild,:Labels,:StopSignal,:StopTimeout,:Shell,:HostConfig,:NetworkingConfig]
        UpdateBody = [:CpuShares, :Memory, :CgroupParent, :BlkioWeight, :BlkioWeightDevice, :BlkioWeightReadBps, :BlkioWeightWriteBps, :BlkioWeightReadOps, :BlkioWeightWriteOps, :CpuPeriod, :CpuQuota, :CpuRealtimePeriod, :CpuRealtimeRuntime, :CpusetCpus, :CpusetMems, :Devices, :DeviceCgroupRules, :DeviceRequest, :Kernel, :Memory, :KernelMemoryTCP, :MemoryReservation, :MemorySwap, :MemorySwappiness, :NanoCPUs, :OomKillDisable, :Init, :PidsLimit, :ULimits, :CpuCount, :CpuPercent, :IOMaximumIOps, :IOMaximumBandwidth, :RestartPolicy]

        class Container < Docker::API::Base

            def base_path
                "/containers"
            end

            def list params = {}
                validate Docker::API::InvalidParameter, [:all, :limit, :size, :filters], params
                @connection.get(build_path(["json"], params))
            end

            def inspect name, params = {}
                validate Docker::API::InvalidParameter, [:size], params
                @connection.get(build_path([name, "json"], params))
            end

            def top name, params = {}
                validate Docker::API::InvalidParameter, [:ps_args], params
                @connection.get(build_path([name, "top"], params))
            end

            def changes name
                @connection.get(build_path([name, "changes"]))
            end

            def start name, params = {}
                validate Docker::API::InvalidParameter, [:detachKeys], params
                @connection.post(build_path([name, "start"], params))
            end

            def stop name, params = {}
                validate Docker::API::InvalidParameter, [:t], params
                @connection.post(build_path([name, "stop"], params))
            end

            def restart name, params = {}
                validate Docker::API::InvalidParameter, [:t], params
                @connection.post(build_path([name, "restart"], params))
            end

            def kill name, params = {}
                validate Docker::API::InvalidParameter, [:signal], params
                @connection.post(build_path([name, "kill"], params))
            end

            def wait name, params = {}
                validate Docker::API::InvalidParameter, [:condition], params
                @connection.post(build_path([name, "wait"], params))
            end

            def update name, body = {}
                validate Docker::API::InvalidRequestBody, Docker::API::UpdateBody, body
                @connection.request(method: :post, path: build_path([name, "update"]), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def rename name, params = {}
                validate Docker::API::InvalidParameter, [:name], params
                @connection.post(build_path([name, "rename"], params))
            end

            def resize name, params = {}
                validate Docker::API::InvalidParameter, [:w, :h], params
                @connection.post(build_path([name, "resize"], params))
            end

            def prune params = {}
                validate Docker::API::InvalidParameter, [:filters], params
                @connection.post(build_path(["prune"], params))
            end

            def pause name
                @connection.post(build_path([name, "pause"]))
            end

            def unpause name
                @connection.post(build_path([name, "unpause"]))
            end

            def remove name, params = {}
                validate Docker::API::InvalidParameter, [:v, :force, :link], params
                @connection.delete(build_path([name]))
            end

            def logs name, params = {}
                validate Docker::API::InvalidParameter, [:follow, :stdout, :stderr, :since, :until, :timestamps, :tail], params
                
                path = build_path([name, "logs"], params)

                if params[:follow] == true || params[:follow] == 1
                    @connection.request(method: :get, path: path , response_block: lambda { |chunk, remaining_bytes, total_bytes| puts chunk.inspect })
                else
                    @connection.get(path)
                end
            end

            def attach name, params = {}
                validate Docker::API::InvalidParameter, [:detachKeys, :logs, :stream, :stdin, :stdout, :stderr], params
                @connection.request(method: :post, path: build_path([name, "attach"], params) , response_block: lambda { |chunk, remaining_bytes, total_bytes| puts chunk.inspect })
            end

            def create params = {}, body = {}
                validate Docker::API::InvalidParameter, [:name], params
                validate Docker::API::InvalidRequestBody, Docker::API::CreateBody, body
                @connection.request(method: :post, path: build_path(["create"], params), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def stats name, params = {}
                validate Docker::API::InvalidParameter, [:stream], params
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
                response = self.inspect(name)
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
                validate Docker::API::InvalidParameter, [:path, :noOverwriteDirNonDir, :copyUIDGID], params

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

        end
    end
end
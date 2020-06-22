module Docker
    module API
        CreateBody = [:Hostname,:Domainname,:User,:AttachStdin,:AttachStdout,:AttachStderr,:ExposedPorts,:Tty,:OpenStdin,:StdinOnce,:Env,:Cmd,:HealthCheck,:ArgsEscaped,:Image,:Volumes,:WorkingDir,:Entrypoint,:NetworkDisabled,:MacAddress,:OnBuild,:Labels,:StopSignal,:StopTimeout,:Shell,:HostConfig,:NetworkingConfig]
        UpdateBody = [:CpuShares, :Memory, :CgroupParent, :BlkioWeight, :BlkioWeightDevice, :BlkioWeightReadBps, :BlkioWeightWriteBps, :BlkioWeightReadOps, :BlkioWeightWriteOps, :CpuPeriod, :CpuQuota, :CpuRealtimePeriod, :CpuRealtimeRuntime, :CpusetCpus, :CpusetMems, :Devices, :DeviceCgroupRules, :DeviceRequest, :Kernel, :Memory, :KernelMemoryTCP, :MemoryReservation, :MemorySwap, :MemorySwappiness, :NanoCPUs, :OomKillDisable, :Init, :PidsLimit, :ULimits, :CpuCount, :CpuPercent, :IOMaximumIOps, :IOMaximumBandwidth, :RestartPolicy]

        class Container

            @@base_path = "/containers"

            def self.list params = {}
                self.validate Docker::API::InvalidParameter, [:all, :limit, :size, :filters], params
                Docker::API::Connection.instance.get(self.build_path(["json"], params))
            end

            def self.inspect name, params = {}
                self.validate Docker::API::InvalidParameter, [:size], params
                Docker::API::Connection.instance.get(self.build_path([name, "json"], params))
            end

            def self.top name, params = {}
                self.validate Docker::API::InvalidParameter, [:ps_args], params
                Docker::API::Connection.instance.get(self.build_path([name, "top"], params))
            end

            def self.changes name
                Docker::API::Connection.instance.get(self.build_path([name, "changes"]))
            end

            def self.start name, params = {}
                self.validate Docker::API::InvalidParameter, [:detachKeys], params
                Docker::API::Connection.instance.post(self.build_path([name, "start"], params))
            end

            def self.stop name, params = {}
                self.validate Docker::API::InvalidParameter, [:t], params
                Docker::API::Connection.instance.post(self.build_path([name, "stop"], params))
            end

            def self.restart name, params = {}
                self.validate Docker::API::InvalidParameter, [:t], params
                Docker::API::Connection.instance.post(self.build_path([name, "restart"], params))
            end

            def self.kill name, params = {}
                self.validate Docker::API::InvalidParameter, [:signal], params
                Docker::API::Connection.instance.post(self.build_path([name, "kill"], params))
            end

            def self.wait name, params = {}
                self.validate Docker::API::InvalidParameter, [:condition], params
                Docker::API::Connection.instance.post(self.build_path([name, "wait"], params))
            end

            def self.update name, body = {}
                self.validate Docker::API::InvalidRequestBody, Docker::API::UpdateBody, body
                Docker::API::Connection.instance.post(self.build_path([name, "update"]), body)
            end

            def self.rename name, params = {}
                self.validate Docker::API::InvalidParameter, [:name], params
                Docker::API::Connection.instance.post(self.build_path([name, "rename"], params))
            end

            def self.resize name, params = {}
                self.validate Docker::API::InvalidParameter, [:w, :h], params
                Docker::API::Connection.instance.post(self.build_path([name, "resize"], params))
            end

            def self.prune params = {}
                self.validate Docker::API::InvalidParameter, [:filters], params
                Docker::API::Connection.instance.post(self.build_path(["prune"], params))
            end

            def self.pause name
                Docker::API::Connection.instance.post(self.build_path([name, "pause"]))
            end

            def self.unpause name
                Docker::API::Connection.instance.post(self.build_path([name, "unpause"]))
            end

            def self.remove name, params = {}
                self.validate Docker::API::InvalidParameter, [:v, :force, :link], params
                Docker::API::Connection.instance.delete(self.build_path([name]))
            end

            def self.logs name, params = {}
                self.validate Docker::API::InvalidParameter, [:follow, :stdout, :stderr, :since, :until, :timestamps, :tail], params
                
                path = self.build_path([name, "logs"], params)

                if params[:follow] == true || params[:follow] == 1
                    Docker::API::Connection.instance.connection.get(path: path , response_block: lambda { |chunk, remaining_bytes, total_bytes| puts chunk.inspect })
                else
                    Docker::API::Connection.instance.get(path)
                end
            end

            def self.attach name, params = {}
                self.validate Docker::API::InvalidParameter, [:detachKeys, :logs, :stream, :stdin, :stdout, :stderr], params
                Docker::API::Connection.instance.connection.request(method: :post, path: self.build_path([name, "attach"], params) , response_block: lambda { |chunk, remaining_bytes, total_bytes| puts chunk.inspect })
            end

            def self.create params = {}, body = {}
                self.validate Docker::API::InvalidParameter, [:name], params
                self.validate Docker::API::InvalidRequestBody, Docker::API::CreateBody, body
                Docker::API::Connection.instance.post(self.build_path(["create"], params), body)
            end

            def self.stats name, params = {}
                self.validate Docker::API::InvalidParameter, [:stream], params
                path = self.build_path([name, "stats"], params)

                if params[:stream] == true || params[:stream] == 1
                    streamer = lambda do |chunk, remaining_bytes, total_bytes|
                        puts chunk
                    end
                    Docker::API::Connection.instance.connection.get(path: path , response_block: streamer)
                else
                    Docker::API::Connection.instance.get(path)
                end
            end

            def self.export name, path = "exported_container"
                response = Docker::API::Container.inspect(name)
                if response.status == 200
                    file = File.open(File.expand_path(path), "wb")
                    streamer = lambda do |chunk, remaining_bytes, total_bytes|
                        file.write(chunk)
                    end
                    response = Docker::API::Connection.instance.connection.get(path: self.build_path([name, "export"]) , response_block: streamer)
                    file.close
                end
                response
            end

            def self.archive name, file, params = {}
                self.validate Docker::API::InvalidParameter, [:path, :noOverwriteDirNonDir, :copyUIDGID], params

                begin # File exists on disk, send it to container
                    file = File.open( File.expand_path( file ) , "r")
                    response = Docker::API::Connection.instance.connection.put(path: self.build_path([name, "archive"], params) , request_block: lambda { file.read(Excon.defaults[:chunk_size]).to_s} )
                    file.close
                rescue Errno::ENOENT # File doesnt exist, get it from container
                    response = Docker::API::Connection.instance.head(self.build_path([name, "archive"], params))
                    if response.status == 200 # file exists in container
                        file = File.open( File.expand_path( file ) , "wb")
                        response = Docker::API::Connection.instance.connection.get(path: self.build_path([name, "archive"], params) , response_block: lambda { |chunk, remaining_bytes, total_bytes| file.write(chunk) })
                        file.close
                    end
                end
                response
            end
      
            private

            def self.validate error, permitted_keys, params
                not_permitted = params.keys - permitted_keys
                raise error if not_permitted.size > 0
            end

            ## Converts Ruby Hash into query parameters
            ## In general, the format is key=value
            ## If value is another Hash, it should keep a json syntax {key:value}
            def self.hash_to_params h
                p = []
                h.each do |k,v|
                    if v.is_a?(Hash)
                        p << "#{k}=#{v.to_json}"
                    else
                        p << "#{k}=#{v}"
                    end
                end
                p.join("&").gsub(" ","")
            end

            def self.build_path path, params = {}
                p = ([@@base_path] << path).join("/")
                params.size > 0 ? [p, self.hash_to_params(params)].join("?") : p
            end
        end
    end
end
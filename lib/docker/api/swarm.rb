module Docker
    module API
        class Swarm < Docker::API::Base

            #################################################
            # Items in this area to be removed before 1.0.0 #
            #################################################
            def inspect
                caller.each { | el | return super.inspect if el.match(/inspector/) }
                warn  "WARNING: #inspect is deprecated and will be removed in the future, please use #details instead."
                details
            end
            #################################################

            def init body = {}
                validate Docker::API::InvalidRequestBody, [:ListenAddr, :AdvertiseAddr, :DataPathAddr, :DataPathPort, :DefaultAddrPool, :ForceNewCluster, :SubnetSize, :Spec], body
                @connection.request(method: :post, path: build_path("/swarm/init"), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def update params = {}, body = {}
                validate Docker::API::InvalidParameter, [:version, :rotateWorkerToken, :rotateManagerToken, :rotateManagerUnlockKey], params
                validate Docker::API::InvalidRequestBody, [:Name, :Labels, :Orchestration, :Raft, :Dispatcher, :CAConfig, :EncryptionConfig, :TaskDefaults], body
                @connection.request(method: :post, path: build_path("/swarm/update", params), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def details
                @connection.get("/swarm")
            end

            def unlock_key
                @connection.get(build_path("/swarm/unlockkey"))
            end

            def unlock body = {}
                validate Docker::API::InvalidRequestBody, [:UnlockKey], body
                @connection.request(method: :post, path: build_path("/swarm/unlock"), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def join body = {}
                validate Docker::API::InvalidRequestBody, [:ListenAddr, :AdvertiseAddr, :DataPathAddr, :RemoteAddrs, :JoinToken], body
                @connection.request(method: :post, path: build_path("/swarm/join"), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def leave params = {}
                validate Docker::API::InvalidParameter, [:force], params
                @connection.post(build_path("/swarm/leave", params))
            end
        end
    end
end
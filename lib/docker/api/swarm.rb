module Docker
    module API
        class Swarm < Docker::API::Base
            def base_path
                "/swarm"
            end

            def init body = {}
                validate Docker::API::InvalidRequestBody, [:ListenAddr, :AdvertiseAddr, :DataPathAddr, :DataPathPort, :DefaultAddrPool, :ForceNewCluster, :SubnetSize, :Spec], body
                @connection.request(method: :post, path: build_path(["init"]), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def update params = {}, body = {}
                validate Docker::API::InvalidParameter, [:version, :rotateWorkerToken, :rotateManagerToken, :rotateManagerUnlockKey], params
                validate Docker::API::InvalidRequestBody, [:Name, :Labels, :Orchestration, :Raft, :Dispatcher, :CAConfig, :EncryptionConfig, :TaskDefaults], body
                @connection.request(method: :post, path: build_path(["update"], params), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def inspect
                @connection.get(base_path)
            end

            def unlock_key
                @connection.get(build_path(["unlockkey"]))
            end

            def unlock body = {}
                validate Docker::API::InvalidRequestBody, [:UnlockKey], body
                @connection.request(method: :post, path: build_path(["unlock"]), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def join body = {}
                validate Docker::API::InvalidRequestBody, [:ListenAddr, :AdvertiseAddr, :DataPathAddr, :RemoteAddrs, :JoinToken], body
                @connection.request(method: :post, path: build_path(["join"]), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def leave params = {}
                validate Docker::API::InvalidParameter, [:force], params
                @connection.post(build_path(["leave"], params))
            end
        end
    end
end
module Docker
    module API
        class Swarm < Docker::API::Base

            def init body = {}
                @connection.request(method: :post, path: build_path("/swarm/init"), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def update params = {}, body = {}
                @connection.request(method: :post, path: build_path("/swarm/update", params), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def details
                @connection.get("/swarm")
            end

            def unlock_key
                @connection.get(build_path("/swarm/unlockkey"))
            end

            def unlock body = {}
                @connection.request(method: :post, path: build_path("/swarm/unlock"), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def join body = {}
                @connection.request(method: :post, path: build_path("/swarm/join"), headers: {"Content-Type": "application/json"}, body: body.to_json)
            end

            def leave params = {}
                @connection.post(build_path("/swarm/leave", params))
            end

            #################################################
            # Items in this area to be removed before 1.0.0 #
            #################################################
            def inspect
                caller.each { | el | return super.inspect if el.match(/inspector/) }
                warn  "WARNING: #inspect is deprecated and will be removed in the future, please use #details instead."
                details
            end
            #################################################
            
        end
    end
end
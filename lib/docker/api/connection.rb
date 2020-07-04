module Docker
    module API
        class Connection
            [:get, :post, :head, :delete, :put].each do | method |
                define_method(method) { | path | self.request(method: method, path: path) }
            end

            def request params
                Docker::API::Response.new(@connection.request(params).data)
            end
            
            def initialize url = nil, params = nil
                url ||= 'unix:///'
                params ||= url == 'unix:///' ? {socket: '/var/run/docker.sock'} : {}
                @connection = Excon.new(url, params)
            end

        end
    end
end
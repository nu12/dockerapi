module Docker
    module API
        class Task < Docker::API::Base

            def list params = {}
                validate Docker::API::InvalidParameter, [:filters], params
                @connection.get(build_path("/tasks",params))
            end

            def details name
                @connection.get("/tasks/#{name}")
            end

            def logs name, params = {}
                validate Docker::API::InvalidParameter, [:details, :follow, :stdout, :stderr, :since, :timestamps, :tail], params
                @connection.get(build_path("/tasks/#{name}/logs", params))
            end

        end
    end
end
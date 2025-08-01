# This class represents the Docker API endpoints regarding tasks.
#
# A task is a container running on a swarm. It is the atomic scheduling unit of swarm. Swarm mode must be enabled for these endpoints to work.
# @see https://docs.docker.com/engine/api/v1.40/#tag/Task
class Docker::API::Task < Docker::API::Base

    # List tasks
    #
    # Docker API: GET /tasks
    # @see https://docs.docker.com/engine/api/v1.40/#operation/TaskList
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def list params = {}
        @connection.get(build_path("/tasks",params))
    end

    # Inspect a task
    #
    # Docker API: GET /tasks/{id}
    # @see https://docs.docker.com/engine/api/v1.40/#operation/TaskInspect
    #
    # @param name [String]: The ID or name of the task.
    def details name
        @connection.get(build_path("/tasks/#{name}"))
    end

    # Get stdout and stderr logs from a task.
    #
    # Docker API: GET /tasks/{id}/logs
    # @see https://docs.docker.com/engine/api/v1.40/#operation/TaskLogs
    #
    # @param name (String) : The ID or name of the task.
    # @param params (Hash) : Parameters that are appended to the URL.
    # @param &block: Replace the default output to stdout behavior.
    def logs name, params = {}, &block
        path = build_path("/tasks/#{name}/logs", params)

        if [true, 1 ].include? params[:follow]
            @connection.request(method: :get, path: path , response_block: block_given? ? block : default_streamer)
        else
            @connection.get(path)
        end
    end
end
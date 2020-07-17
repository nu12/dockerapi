# This class represents the Docker API endpoints regarding tasks.
#
# @see https://docs.docker.com/engine/api/v1.40/#tag/Task
#
# A task is a container running on a swarm. It is the atomic scheduling unit of swarm. Swarm mode must be enabled for these endpoints to work.
class Docker::API::Task < Docker::API::Base

    # List tasks
    #
    # Docker API: GET /tasks
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/TaskList
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def list params = {}
        validate Docker::API::InvalidParameter, [:filters], params
        @connection.get(build_path("/tasks",params))
    end

    # Inspect a task
    #
    # Docker API: GET /tasks/{id}
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/TaskInspect
    #
    # @param name [String]: The ID or name of the task.
    def details name
        @connection.get("/tasks/#{name}")
    end

    # Get stdout and stderr logs from a task.
    #
    # Note: This endpoint works only for services with the local, json-file or journald logging drivers.
    #
    # Docker API: GET /tasks/{id}/logs
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/TaskLogs
    #
    # @param name (String) : The ID or name of the task.
    #
    # @param params (Hash) : Parameters that are appended to the URL.
    def logs name, params = {}
        validate Docker::API::InvalidParameter, [:details, :follow, :stdout, :stderr, :since, :timestamps, :tail], params
        @connection.get(build_path("/tasks/#{name}/logs", params))
    end
end
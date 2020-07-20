# This class represents the Docker API endpoints regarding plugins.
#
# @see https://docs.docker.com/engine/api/v1.40/#tag/Plugin
class Docker::API::Plugin < Docker::API::Base

    # List plugins
    #
    # Docker API: GET /plugins
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/PluginList
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def list params = {}
        validate Docker::API::InvalidParameter, [:filters], params
        @connection.get(build_path("/plugins", params))
    end

    # Get plugin privileges
    #
    # Docker API: GET /plugins/privileges
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/GetPluginPrivileges
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def privileges params = {}
        validate Docker::API::InvalidParameter, [:remote], params
        @connection.get(build_path("/plugins/privileges", params))
    end

    # Install a plugin
    #
    # Pulls and installs a plugin. After the plugin is installed, it can be enabled using the POST /plugins/{name}/enable endpoint.
    #
    # Docker API: POST /plugins/pull
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/PluginPull
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    #
    # @param privileges [Array]: Plugin privileges to be sent as json in request body.
    #
    # @param authentication [Hash]: Authentication parameters.
    def install params = {}, privileges = [], authentication = {}
        validate Docker::API::InvalidParameter, [:remote, :name], params
        @connection.request(method: :post, path: build_path("/plugins/pull", params), headers: {"Content-Type": "application/json"}, body: privileges.to_json )
    end

    # 
    #
    # Docker API: 
    #
    # @see 
    #
    # @param 
    def details
    end

    # 
    #
    # Docker API: 
    #
    # @see 
    #
    # @param 
    def remove name
        @connection.delete("/plugins/#{name}")
    end

    # 
    #
    # Docker API: 
    #
    # @see 
    #
    # @param 
    def enable
    end

    # 
    #
    # Docker API: 
    #
    # @see 
    #
    # @param 
    def disable
    end

    # 
    #
    # Docker API: 
    #
    # @see 
    #
    # @param 
    def upgrade
    end

    # 
    #
    # Docker API: 
    #
    # @see 
    #
    # @param 
    def create
    end

    # 
    #
    # Docker API: 
    #
    # @see 
    #
    # @param 
    def push
    end

    # 
    #
    # Docker API: 
    #
    # @see 
    #
    # @param 
    def configure
    end

end
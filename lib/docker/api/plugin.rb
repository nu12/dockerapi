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
        headers = {"Content-Type": "application/json"}
        headers.merge!({"X-Registry-Auth" => Base64.urlsafe_encode64(authentication.to_json.to_s)}) if authentication.keys.size > 0
        @connection.request(method: :post, path: build_path("/plugins/pull", params), headers: headers, body: privileges.to_json )
    end

    # Inspect a plugin
    #
    # Docker API: GET /plugins/{name}/json
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/PluginInspect
    #
    # @param name [String]: The ID or name of the plugin.
    def details name 
        @connection.get("/plugins/#{name}/json")
    end

    # Remove a plugin
    #
    # Docker API: DELETE /plugins/{name}
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/PluginDelete
    #
    # @param name [String]: The ID or name of the plugin.
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def remove name, params = {}
        @connection.delete(build_path("/plugins/#{name}",params))
    end

    # Enable a plugin
    #
    # Docker API: POST /plugins/{name}/enable
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/PluginEnable
    #
    # @param name [String]: The ID or name of the plugin.
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    def enable name, params = {}
        @connection.post(build_path("/plugins/#{name}/enable", params))
    end

    # Disable a plugin
    #
    # Docker API: POST /plugins/{name}/disable
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/PluginDisable
    #
    # @param name [String]: The ID or name of the plugin.
    def disable name
        @connection.post("/plugins/#{name}/disable")
    end

    # Upgrade a plugin
    #
    # Docker API: POST /plugins/{name}/upgrade
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/PluginUpgrade
    #
    # @param name [String]: The ID or name of the plugin.
    #
    # @param params [Hash]: Parameters that are appended to the URL.
    #
    # @param privileges [Array]: Plugin privileges to be sent as json in request body.
    #
    # @param authentication [Hash]: Authentication parameters.
    def upgrade name, params = {}, privileges = [], authentication = {}
        headers = {"Content-Type": "application/json"}
        headers.merge!({"X-Registry-Auth" => Base64.urlsafe_encode64(authentication.to_json.to_s)}) if authentication.keys.size > 0
        @connection.request(method: :post, path: build_path("/plugins/#{name}/upgrade", params), headers: headers, body: privileges.to_json )
    end

    # Create a plugin
    #
    # Docker API: POST /plugins/create
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/PluginCreate
    #
    # @param name [String]: The ID or name of the plugin.
    #
    # @param path [String]: Path to tar file that contains rootfs folder and config.json file.
    def create name, path
        file = File.open( File.expand_path( path ) , "r")
        response = @connection.request(method: :post, path: "/plugins/create?name=#{name}", body: file.read.to_s )
        file.close        
        response
    end

    # Push a plugin to the registry.
    #
    # Docker API: POST /plugins/{name}/push
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/PluginPush
    #
    # @param name [String]: The ID or name of the plugin.
    #
    # @param authentication [Hash]: Authentication parameters.
    def push name, authentication = {}
        if authentication.keys.size > 0
            @connection.request(method: :post, path: "/plugins/#{name}/push", headers: {"X-Registry-Auth" => Base64.urlsafe_encode64(authentication.to_json.to_s)})
        else
            @connection.post("/plugins/#{name}/push")
        end
    end

    # Configure a plugin
    #
    # Docker API: POST /plugins/{name}/set
    #
    # @see https://docs.docker.com/engine/api/v1.40/#operation/PluginSet
    #
    # @param name [String]: The ID or name of the plugin.
    #
    # @param config [Array]: Plugin configuration to be sent as json in request body.
    def configure name, config
        @connection.request(method: :post, path: "/plugins/#{name}/set", headers: {"Content-Type": "application/json"}, body:config.to_json)
    end

end
##
# Connection class.
class Docker::API::Connection
    attr_reader(:excon)
    
    ##
    # Create an Excon connection.
    #
    # @param url [String]: URL for the connection.
    # @param params [String]: Additional parameters.
    def initialize url = nil, params = {}
        return @excon = Excon.new('unix:///', params.merge({socket: '/var/run/docker.sock'})) unless url
        @excon = Excon.new(url, params)
    end

end
##
# Connection class.
class Docker::API::Connection
    [:get, :post, :head, :delete, :put].each do | method |
        define_method(method) { | path | self.request(method: method, path: path) }
    end

    ##
    # Call an Excon request and returns a Docker::API::Response object.
    #
    # @param params [Hash]: Request parameters.
    def request params
        response = Docker::API::Response.new(@connection.request(params).data)
        p response if Docker::API::PRINT_RESPONSE_TO_STDOUT 
        response
    end
    
    ##
    # Create an Excon connection.
    #
    # @param url [String]: URL for the connection.
    # @param params [String]: Additional parameters.
    def initialize url = nil, params = nil
        return @connection = Excon.new('unix:///', {socket: '/var/run/docker.sock'}) unless url
        @connection = Excon.new(url, params || {})
    end

end
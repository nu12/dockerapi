##
# Base class to provide general methods, helpers and implementations accross classes.
class Docker::API::Base
    [:get, :post, :head, :delete, :put].each do | method |
        define_method(method) { | path | self.request(method: method, path: path) }
    end

    ##
    # Call an Excon request and returns a Docker::API::Response object.
    #
    # @param params [Hash]: Request parameters.
    def request params
        response = Docker::API::Response.new(@connection.excon.request(params).data)
        response.request_params = params
        p response if Docker::API.print_response_to_stdout 
        response
    end
    
    ##
    # Create new object and sets the validation to happen automatically when method parameters include "params" or "body".
    #
    # @param connection [Docker::API::Connection]: Connection to be used.
    def initialize connection = nil
        raise StandardError.new("Expected connection to be a Docker::API::Connection class") if connection != nil && !connection.is_a?(Docker::API::Connection)
        @connection = connection || Docker::API::Connection.new
    end
    
    private

    ##
    # Output to stdout.
    def default_streamer
        streamer = lambda do |chunk, remaining_bytes, total_bytes|
            p chunk.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?') if Docker::API.print_to_stdout
        end
        streamer
    end

    ##
    # Write file to disk.
    #
    # @param path [String]: Path to the file to be writen.
    def default_writer path
        streamer = lambda do |chunk, remaining_bytes, total_bytes|
            return if "#{chunk}".match(/(No such image)/)
            file = File.open(File.expand_path(path), "wb+")
            file.write(chunk)
            file.close
        end
        streamer
    end

    ##
    # Read file from disk.
    #
    # @param path [String]: Path to the file to be read.
    # @param url [String]: Endpoint URL where the file is going to be sent.
    # @param header [Hash]: Header of the request.
    # @param &block: Replace the default output to stdout behavior.
    def default_reader path, url, header = {"Content-Type" => "application/x-tar"}, &block
        file = File.open(File.expand_path(path), "r")
        response = request(method: :post, path: url , headers: header, request_block: lambda { file.read(Excon.defaults[:chunk_size]).to_s}, response_block: block_given? ? block : default_streamer )
        file.close
        response
    end

    ##
    # Encode authentication parameters.
    #
    # @param authentication [Hash]: Parameters to be encoded.
    def auth_encoder(authentication)
        Base64.urlsafe_encode64(authentication.to_json.to_s).chomp
    end

    ##
    # Convert Ruby Hash into URL query parameters.
    #
    # In general, query parameters' format is "key=value", but if "value" is another Hash, it should change to a json syntax {key:value}.
    #
    # @param hash [Hash]: Hash object to be converted in a query parameter-like string.
    def hash_to_params hash
        p = []
        hash.each { |k,v| p.push( v.is_a?(Hash) ? "#{k}=#{v.to_json}" : "#{k}=#{v}") }
        p.join("&").gsub(" ","")
    end

    ##
    # Build an URL string using the base path and a set of parameters.
    #
    # @param path [String]: Base URL string.
    # @param hash [Hash]: Hash object to be appended to the URL as query parameters.
    def build_path path, params = {}
        path = "/v#{Docker::API::API_VERSION}#{path}"
        params.size > 0 ? [path, hash_to_params(params)].join("?") : path
    end

end
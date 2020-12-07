##
# Reponse class.
class Docker::API::Response < Excon::Response
    attr_reader(:json, :path)

    ##
    # Initialize a new Response object.
    #
    # @params data [Object]: Reponse's data.
    def initialize data
        super data
        @json = parse_json @body
        @path = @data[:path]
    end

    ##
    # Return true if Response status is in 200..204 range.
    def success?
        (200..204).include? @status
    end

    private

    ##
    # Create a json from Response data attribute.
    #
    # @params data [String]: String to be converted in json.
    def parse_json data
        return nil unless headers["Content-Type"] == "application/json"
        return nil if data == ""
        data.split("\r\n").size > 1 ? data.split("\r\n").map{ |e| eval(e) } : JSON.parse(data)
    end
end
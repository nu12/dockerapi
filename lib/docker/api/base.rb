class Docker::API::Base
    

    def initialize connection = nil
        raise Docker::API::Error.new("Expected connection to be a Docker::API::Connection class") if connection != nil && !connection.is_a?(Docker::API::Connection)
        @connection = connection || Docker::API::Connection.new
        
        (self.methods - Object.methods).each do |method|
            params_index = method(method).parameters.map{|ar| ar[1]}.index(:params)
            body_index = method(method).parameters.map{|ar| ar[1]}.index(:body)

            define_singleton_method(method) do |*args, &block|
                validate Docker::API::InvalidParameter, Docker::API::VALID_PARAMS["#{self.class.name}"]["#{method}"], (args[params_index] || {}) if params_index
                validate Docker::API::InvalidRequestBody, Docker::API::VALID_BODY["#{self.class.name}"]["#{method}"], (args[body_index] || {}) if body_index
                super(*args,&block)
            end
        end
    end
    
    private

    def default_streamer
        streamer = lambda do |chunk, remaining_bytes, total_bytes|
            p chunk.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?') if Docker::API::PRINT_TO_STDOUT
        end
        streamer
    end

    def default_writer path
        streamer = lambda do |chunk, remaining_bytes, total_bytes|
            return if "#{chunk}".match(/(No such image)/)
            file = File.open(File.expand_path(path), "wb+")
            file.write(chunk)
            file.close
        end
        streamer
    end

    def default_reader path, url, header = {"Content-Type" => "application/x-tar"}, &block
        file = File.open(File.expand_path(path), "r")
        response = @connection.request(method: :post, path: url , headers: header, request_block: lambda { file.read(Excon.defaults[:chunk_size]).to_s}, response_block: block_given? ? block.call : default_streamer )
        file.close
        response
    end

    def validate error, permitted, params
        return if params[:skip_validation]
        unpermitted = params.keys.map(&:to_s) - permitted.map(&:to_s)
        raise error.new(permitted, unpermitted) if unpermitted.size > 0
    end

    ## Converts Ruby Hash into query parameters
    ## In general, the format is key=value
    ## If value is another Hash, it should keep a json syntax {key:value}
    def hash_to_params h
        p = []
        h.delete_if{ | k, v | k.to_s == "skip_validation" }.each { |k,v| p.push( v.is_a?(Hash) ? "#{k}=#{v.to_json}" : "#{k}=#{v}") }
        p.join("&").gsub(" ","")
    end

    def build_path path, params = {}
        p = path.is_a?(Array) ? ([base_path] << path).join("/") : path # TODO: this line to be removed?
        params.size > 0 ? [p, hash_to_params(params)].join("?") : p
    end

end
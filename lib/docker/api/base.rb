module Docker
    module API
        class Base

            def initialize connection = nil
                raise Docker::API::Error.new("Expect connection to be a Docker::API::Connection class") if connection != nil && !connection.is_a?(Docker::API::Connection)
                @connection = connection || Docker::API::Connection.new
            end
            
            private

            def base_path # TODO: this method to be removed?
                "/"
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
    end
end
module Docker
    module API
        class Base
            
            private

            def self.base_path
                "/"
            end

            def self.connection
                Docker::API::Connection.instance
            end

            def self.validate error, permitted_keys, params
                not_permitted = params.keys - permitted_keys
                raise error if not_permitted.size > 0
            end

            ## Converts Ruby Hash into query parameters
            ## In general, the format is key=value
            ## If value is another Hash, it should keep a json syntax {key:value}
            def self.hash_to_params h
                p = []
                h.each { |k,v| p.push( v.is_a?(Hash) ? "#{k}=#{v.to_json}" : "#{k}=#{v}") }
                p.join("&").gsub(" ","")
            end

            def self.build_path path, params = {}
                p = path.is_a?(Array) ? ([base_path] << path).join("/") : path
                params.size > 0 ? [p, hash_to_params(params)].join("?") : p
            end

        end
    end
end
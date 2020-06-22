module Docker
    module API
        class Image

            @@base_path = "/images"

            def self.create query_params = {}
                Docker::API::Connection.instance.post(self.build_path(["create"], query_params))
            end

            def self.remove name, query_params = {}
                Docker::API::Connection.instance.delete(self.build_path([name],  query_params))
            end

            private

            def self.build_path path, params = {}
                p = ([@@base_path] << path).join("/")
                params.size > 0 ? [p, params.map {|k,v| "#{k}=#{v}"}.join("&")].join("?") : p
            end
        end

    end
end
module Docker
    module API
        class Image < Docker::API::Base

            def self.base_path
                "/images"
            end

            def self.create params = {}
                connection.post(build_path(["create"], params))
            end

            def self.remove name, params = {}
                connection.delete(build_path([name], params))
            end
        end

    end
end